describe LoggerFacade::Plugins::Logstash do

  let(:filename) { "./spec/log.logstash" }
  let(:time) { Time.new(1983, 01, 25, 13, 10, 01, '+00:00') }

  before(:each) do
    FileUtils.rm(filename) rescue nil
    allow(Time).to receive(:now) { time }
    LoggerFacade::Manager.clear_plugins
    config = { level: :debug, filename: filename }
    plugin = LoggerFacade::Plugins::Logstash.new(config)
    LoggerFacade::Manager.use(plugin)
  end

  after(:each) do
    FileUtils.rm(filename)
  end

  let(:log) do
    LoggerFacade::Manager.get_logger 'SPEC_LOGGER'
  end

  it 'logs to file' do
    log.debug("message info", { context: true })
    logline = "{\"@timestamp\":\"1983-01-25T13:10:01Z\",\"@fields\":{\"context\":true,\"pid\":#{Process.pid},\"severity\":\"debug\",\"logger\":\"SPEC_LOGGER\",\"message\":\"message info\"}}\n"
    expect(File.read(filename)).to eq(logline)
  end

end
