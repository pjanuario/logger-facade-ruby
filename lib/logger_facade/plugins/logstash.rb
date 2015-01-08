require 'logger'
require 'yajl'

module LoggerFacade::Plugins
  class Logstash < Base

    def initialize(configuration = {})
      super("LoggerFacade::Plugins::Logstash", configuration)

      fail "Invalid configuration filename: #{config.filename}" unless config.filename

      @logdevice = if config["device"]
        shift_age = config.device["shift_age"]
        shift_size = config.device["shift_size"]
        LogDeviceWithRotation.new(config.filename, shift_age, shift_size)
      else
        LogDeviceWithoutRotation.new(config.filename)
      end
    end

    private

    attr_reader :logdevice

    def log(severity, message, logger, metadata)
      return unless is_level_active(severity)
      return unless logdevice

      ts = metadata.delete :timestamp
      ts ||= Time.now.utc
      metadata[:severity] = severity
      metadata[:logger] = logger
      metadata[:message] = message
      metadata[:backtrace] = message.backtrace if message.is_a? Exception

      json = {
       '@timestamp' => ts.iso8601,
       '@fields'    => metadata
      }
      
      @logdevice.write("#{Yajl::Encoder.encode(json)}\n")
    end

    class LogDeviceWithRotation < ::Logger::LogDevice

      private

      # overrides base.add_log_header to disable log header
      def add_log_header(file)
      end
    end

    class LogDeviceWithoutRotation < LogDeviceWithRotation

      # overrides base.write to disable log shifting
      def write(message)
        @mutex.synchronize do
          @dev.write(message)
        end
      end
    end

  end
end
