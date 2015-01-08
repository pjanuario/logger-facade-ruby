require 'hashie'

module LoggerFacade::Plugins

  class Console < Base

    def initialize(config = {})
      defaults = {
        level: :info,
        time_format: '%y-%M-%d %H:%M:%S',
        message_format: '%time | %level | %logger - %msg'
      }
      config = defaults.merge(config)
      super("LoggerFacade::Plugins::Console", config)
    end

    protected

    def log(log_level, message, logger, metadata)
      return unless is_level_active(log_level)

      write message(log_level, message, logger, metadata)
    end

    private

    def message(level, msg, logger, metadata)
      msg = log_exception(msg) if msg.is_a? Exception

      timestamp = metadata[:timestamp] || Time.now.utc
      pid = metadata[:pid] || Process.pid

      config.message_format
        .gsub('%logger', logger.upcase)
        .gsub('%time', timestamp.strftime(config.time_format))
        .gsub('%level', level.to_s.upcase)
        .gsub('%pid', pid.to_s)
        .gsub('%msg', msg)
    end

    def log_exception(msg)
      "#{msg.message}\n#{(msg.backtrace || []).join("\n")}"
    end

    def write(message)
      Kernel.puts message
    end

  end

end
