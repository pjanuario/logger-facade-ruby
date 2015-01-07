require 'spec_helper'

describe LoggerFacade::Log do

  let(:plugin) { double('plugin').as_null_object }

  subject { described_class.new('log', [plugin]) }

  describe('#isDebug') do

    context('when exists a plugin configured in debug levels') do

      it('returns true') do
        allow(plugin).to receive(:is_debug) { true }
        expect(subject.is_debug).to be true
      end

    end

    context('when does not exists a plugin configured in debug levels') do

      it('returns false') do
        allow(plugin).to receive(:is_debug) { true }
        expect(subject.is_debug).to be true
      end

    end

    context('when does not exists plugins') do

      subject { described_class.new('log', []) }

      it('returns false') do
        expect(subject.is_debug).to be false
      end

    end

  end

  %w(trace debug info warn error).each do |level|

    describe("##{level}") do

      it("calls the plugin in #{level} level") do
        message = "call with message"
        expect(plugin).to receive(level.to_sym).with(subject.name, message, anything)
        subject.send(level.to_sym, message)
      end

      it("calls the plugin with metadata") do
        message = "call with message"
        metadata = double('metadata')
        expect(plugin).to receive(level.to_sym)
          .with(subject.name, message, hash_including(:metadata))
        subject.send(level.to_sym, message, metadata)
      end

    end

  end

end
