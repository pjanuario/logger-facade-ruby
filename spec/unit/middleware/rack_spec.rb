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

  context 'severity' do

    it "log 200 status to info" do
      expect(logger).to receive(:info)
      Rack::MockRequest.new(described_class.new(app)).get("/path")
    end

    it "log 300 status to info" do
      expect(logger).to receive(:info)
      Rack::MockRequest.new(described_class.new(app)).get("/path")
    end

    it "log 400 status to warn" do
      expect(logger).to receive(:warn)
      app = -> (env) { [400, env, "app"] }
      Rack::MockRequest.new(described_class.new(app)).get("/path")
    end

    it "log 500 status to error" do
      expect(logger).to receive(:error)
      app = -> (env) { [500, env, "app"] }
      Rack::MockRequest.new(described_class.new(app)).get("/path")
    end

  end

  context 'with proper metadata' do

    after do
      with_mock_time do
        Rack::MockRequest.new(described_class.new(app)).get("/path?q=true")
      end
    end

    it "log clientip as metadata" do
      expect(logger).to receive(:info)
        .with(anything, hash_including("clientip"))
    end

    it "log verb as metadata" do
      expect(logger).to receive(:info)
        .with(anything, hash_including("verb" => "GET"))
    end

    it "log request as metadata" do
      expect(logger).to receive(:info)
        .with(anything, hash_including("request" => "/path?q=true"))
    end

    it "log http_version as metadata" do
      expect(logger).to receive(:info)
        .with(anything, hash_including("http_version" => nil))
    end

    it "log response as metadata" do
      expect(logger).to receive(:info)
        .with(anything, hash_including("response" => "200"))
    end

    it "log bytes as metadata" do
      expect(logger).to receive(:info)
        .with(anything, hash_including("bytes" => length))
    end

    it "log referrer as metadata" do
      expect(logger).to receive(:info)
        .with(anything, hash_including("referrer" => nil))
    end

    it "log agent as metadata" do
      expect(logger).to receive(:info)
        .with(anything, hash_including("agent" => nil))
    end

    it "log request_time as metadata" do
      expect(logger).to receive(:info)
        .with(anything, hash_including("request_time" => 0.0))
    end

    it "log request_full_url as metadata" do
      expect(logger).to receive(:info)
        .with(anything, hash_including("request_full_url" => nil))
    end
  end
end
