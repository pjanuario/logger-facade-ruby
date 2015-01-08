require 'spec_helper'

describe LoggerFacade::Plugins::Console do
  include LevelTestHelper

  subject { described_class.new }

  let(:time) { Time.new(1983, 01, 25, 13, 10, 01, '+00:00') }
  let(:metadata){ { timestamp: time, pid: 100 } }

  before :each do
    allow(Time).to receive(:now) { time }
  end

  describe('#is_debug') do

    it('returns true when log level lower than info') do
      subject = described_class.new({ level: :debug })
      expect(subject.is_debug).to be true
    end

    it('returns false when log level higher than debug') do
      expect(subject.is_debug).to be false
    end

  end

  %w(trace debug info warn error).each do |level|

    context("logging in #{level} level") do
      subject { described_class.new({ level: level.to_sym }) }

      context("when plugin log level lower or equal than #{level}") do

        it("writes to stdout") do
          message = "call with message"
          expect(Kernel).to receive(:puts)
            .with("83-10-25 13:10:01 | #{level.upcase} | NAME - call with message")
          subject.send(level.to_sym, "name", message)
        end

      end

      unless level == 'error'
        context("when plugin log level higher than #{level}") do

          subject { described_class.new({ level: next_level(level) }) }

          it("doesn't write to stdout") do
            message = "call with message"
            expect(Kernel).not_to receive(:puts)
            subject.send(level.to_sym, "name", message)
          end

        end
      end

    end

  end

  it('log an exception') do
    error = Exception.new('test log')
    expect(Kernel).to receive(:puts)
      .with("83-10-25 13:10:01 | ERROR | NAME - test log\n")
    subject.error("name", error)
  end

end
