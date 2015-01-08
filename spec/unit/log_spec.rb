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
      let(:time) { Time.new(1983, 01, 25, 13, 10, 01, '+00:00') }
      let(:pid) { 0 }

      it("calls the plugin in #{level} level") do
        message = "call with message"
        expect(plugin).to receive(level.to_sym).with(subject.name, message, anything)
        subject.send(level.to_sym, message)
      end

      it("calls the plugin with metadata dictionary when not present") do
        message = "call with message"
        metadata = {}
        expect(plugin).to receive(level.to_sym)
          .with(subject.name, message,
            hash_including(metadata: hash_including(:timestamp, :pid)))
        subject.send(level.to_sym, message)
      end

      it("appends timestamp to metadata") do
        allow(Time).to receive(:now) { time }
        message = "call with message"
        metadata = {}
        expect(plugin).to receive(level.to_sym)
          .with(subject.name, message,
            hash_including(metadata: hash_including(timestamp: time))
          )
        subject.send(level.to_sym, message, metadata)
      end

      it("appends timestamp to metadata") do
        allow(Time).to receive(:now) { time }
        message = "call with message"
        metadata = {}
        expect(plugin).to receive(level.to_sym)
          .with(subject.name, message,
            hash_including(metadata: hash_including(timestamp: time))
          )
        subject.send(level.to_sym, message, metadata)
      end

      it("appends pid to metadata") do
        allow(Process).to receive(:pid) { pid }
        message = "call with message"
        metadata = {}
        expect(plugin).to receive(level.to_sym)
          .with(subject.name, message,
            hash_including(metadata: hash_including(pid: pid))
          )
        subject.send(level.to_sym, message, metadata)
      end

    end

  end

end
