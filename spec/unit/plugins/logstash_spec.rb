describe LoggerFacade::Plugins::Logstash do
  include LevelTestHelper

  subject { described_class.new }

  let(:filename) { './test.log' }
  let(:config) { { filename: filename } }
  let(:time) { Time.new(1983, 01, 25, 13, 10, 01, '+00:00') }
  let(:metadata){ { timestamp: time, pid: 100 } }
  let(:file) { double('file') }

  before :each do
    allow(Time).to receive(:now) { time }
    allow_any_instance_of(Object).to receive(:open) { file }
    allow_any_instance_of(Object).to receive(:sync=)
  end

  describe("initialize") do
    it 'defaults to logdevice without rotation' do
      expect(LoggerFacade::Plugins::Logstash::LogDeviceWithoutRotation)
        .to receive(:new).with(filename)
      described_class.new(config)
    end

    it 'uses ruby Logger config' do
      age = 'age'
      size = 1024
      config[:device] = { shift_age: age, shift_size: size }
      expect(LoggerFacade::Plugins::Logstash::LogDeviceWithRotation)
        .to receive(:new).with(filename, age, size)
      described_class.new(config)
    end

    it 'raises an error on invalid filename configuration' do
      expect { described_class.new({}) }.to raise_exception(RuntimeError)
    end
  end

  describe('#is_debug') do

    it('returns true when log level lower than info') do
      subject = described_class.new(config)
      expect(subject.is_debug).to be true
    end

    it('returns false when log level higher than debug') do
      config[:level] = :info
      subject = described_class.new(config)
      expect(subject.is_debug).to be false
    end

  end

  %w(trace debug info warn error).each do |level|

    context("logging in #{level} level") do
      subject do
        config[:level] = level.to_sym
        described_class.new(config)
      end

      let(:message) { "call with message" }
      let(:logger) { "name" }
      let(:severity) { level.to_sym }

      context("when plugin log level lower or equal than #{level}") do

        it("writes to file") do
          expect(file).to receive(:write)
          subject.send(severity, logger, message)
        end

        context 'format' do
          it("writes a valid json") do
            expect(file).to receive(:write) do |msg|
              data = nil
              expect { data = Yajl::Parser.new.parse(msg) }.not_to raise_exception
              expect(data).to be
            end
            subject.send(severity, logger, message)
          end

          it("ends with line break") do
            expect(file).to receive(:write) do |msg|
              expect(msg[-1,1]).to eq("\n")
            end
            subject.send(severity, logger, message)
          end

          context 'timestamp' do
            # time + 1.month
            let(:ts) { time + 2592000 }
            let(:metadata) { { timestamp: ts } }

            it("writes logstash timestamp format") do
              expect(file).to receive(:write) do |msg|
                data = Yajl::Parser.new.parse(msg)
                expect(data["@timestamp"]).to eq(time.iso8601)
              end
              subject.send(severity, logger, message)
            end

            it("uses metadata timestamp") do
              expect(file).to receive(:write) do |msg|
                data = Yajl::Parser.new.parse(msg)
                expect(data["@timestamp"]).to eq(ts.iso8601)
              end
              subject.send(severity, logger, message, metadata: metadata)
            end

            it("doesn't write field timestamp") do
              expect(file).to receive(:write) do |msg|
                data = Yajl::Parser.new.parse(msg)["@fields"]
                expect(data["timestamp"]).to be_nil
              end
              subject.send(severity, logger, message, metadata: metadata)
            end
          end

          it("writes fields") do
            expect(file).to receive(:write) do |msg|
              data = Yajl::Parser.new.parse(msg)
              expect(data["@fields"]).to be
            end
            subject.send(severity, logger, message)
          end

          it("writes severity") do
            expect(file).to receive(:write) do |msg|
              data = Yajl::Parser.new.parse(msg)["@fields"]
              expect(data["severity"]).to eq(severity.to_s)
            end
            subject.send(severity, logger, message)
          end

          it("writes logger") do
            expect(file).to receive(:write) do |msg|
              data = Yajl::Parser.new.parse(msg)["@fields"]
              expect(data["logger"]).to eq(logger)
            end
            subject.send(severity, logger, message)
          end

          it("writes message") do
            expect(file).to receive(:write) do |msg|
              data = Yajl::Parser.new.parse(msg)["@fields"]
              expect(data["message"]).to eq(message)
            end
            subject.send(severity, logger, message)
          end

          it("writes other metadata fields") do
            metadata = { context: true }
            expect(file).to receive(:write) do |msg|
              data = Yajl::Parser.new.parse(msg)["@fields"]
              expect(data["context"]).to eq(true)
            end
            subject.send(severity, logger, message, metadata: metadata)
          end

          context "on excepetion parameter" do

            it('writes the exception message') do
              error = Exception.new('test log')
              expect(file).to receive(:write) do |msg|
                data = Yajl::Parser.new.parse(msg)["@fields"]
                expect(data["message"]).to eq("test log")
              end
              subject.send(severity, logger, error)
            end

            it('writes the exception backtrace') do
              error = Exception.new('test log')
              error.set_backtrace "stacktrace"
              expect(file).to receive(:write) do |msg|
                data = Yajl::Parser.new.parse(msg)["@fields"]
                expect(data["backtrace"]).to eq(error.backtrace)
              end
              subject.send(severity, logger, error)
            end
          end
        end

      end

      unless level == 'error'
      context("when plugin log level higher than #{level}") do
        subject do
          config[:level] = next_level(level)
          described_class.new(config)
        end

        it("doesn't write to file") do
          expect(file).not_to receive(:write)
          subject.send(level.to_sym, "name", message)
        end

      end
      end

    end

  end

end
