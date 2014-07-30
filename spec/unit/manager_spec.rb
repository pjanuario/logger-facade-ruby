require 'spec_helper'

describe LoggerFacade::Manager do

  let :plugin do
    plugin = double('plugin').as_null_object
    allow(plugin).to receive(:name) { "mock_plugin" }
    plugin
  end

  before(:each) { described_class.clear_plugins }

  describe('.use') do

    it('register a plugin') do
      described_class.use(plugin)
      expect(described_class.plugins).to eq(['mock_plugin'])
    end

    it('does not register nil plugin') do
      expect { described_class.use(nil) }.to raise_exception
    end

  end


  describe('.plugins') do

    before(:each) { described_class.use(plugin) }

    it('returns registered plugins name') do
      expect(described_class.plugins).to eq(['mock_plugin'])
    end

  end


  describe('.clear_plugins') do

    before(:each) { described_class.use(plugin) }

    it('removes all registered plugins') do
      described_class.clear_plugins
      expect(described_class.plugins).to eq([])
    end

  end


  describe('.get_logger') do

    it('returns a logger instance') do
      log = described_class.get_logger('log')
      expect(log).to be_truthy
      expect(log.name).to eq('log')
    end

  end

end
