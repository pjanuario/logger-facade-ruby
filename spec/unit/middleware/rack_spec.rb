require 'rack/commonlogger'
require 'rack/lint'
require 'rack/mock'
require 'logger_facade'
require 'logger_facade/middleware/rack'

describe LoggerFacade::Middleware::Rack do
  include TimeTestHelper
  let(:regex) do
    /(-) "(\w+) \/(\w+)\?(q=\w+)" (\d{3}) (\d+) ([\d\.]+)/
  end
  let(:logger) { double('logger') }
  let(:obj) { "foobar" }
  let(:length) { obj.size }
  let(:app) do
    Rack::Lint.new lambda { |env|
      [200,
       {"Content-Type" => "text/html", "Content-Length" => length.to_s},
       [obj]]}
  end

  before do
    expect(LoggerFacade::Manager).to receive(:get_logger){ logger }
  end

  it "logs to logger facade instance" do
    expect(logger).to receive(:info)#.with('- "GET /" 200 6 0.0007')
    res = Rack::MockRequest.new(described_class.new(app)).get("/")
  end

  it "log in the specified log format" do
    expect(logger).to receive(:info) do |message|
      md = regex.match(message)
      expect(md).not_to be_nil
      ip, method, path, qs, status, size, duration = *md.captures
      expect(ip).to eq("-")
      expect(method).to eq("GET")
      expect(path).to eq("path")
      expect(qs).to eq("q=true")
      expect(status).to eq("200")
      expect(size).to eq(length.to_s)
      expect(duration.to_f).to eq(0)
    end
    with_mock_time do
      Rack::MockRequest.new(described_class.new(app)).get("/path?q=true")
    end
  end

  it "log with metadata" do
    expect(logger).to receive(:info)
      .with(anything, {
        'client_ip'     => nil,
        'method'        => "GET",
        'path'          => "/path",
        'query_string'  => "q=true",
        'status'        => 200,
        'size'          => 6,
        'response_time' => 0.0
      })
    with_mock_time do
      Rack::MockRequest.new(described_class.new(app)).get("/path?q=true")
    end
  end
end
