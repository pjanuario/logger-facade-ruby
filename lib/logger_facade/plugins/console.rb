require 'hashie'

module LoggerFacade::Plugins

  class Console

    attr_reader :config, :level, :name

    def initialize(config = {})
      defaults = {
        level: :info,
        time_format: '%y-%M-%d %H:%M:%S',
        message_format: '%time | %level | %logger - %msg'
      }
      config = defaults.merge(config)

      @config = Hashie::Mash.new(config)
      @level = @config.level.to_sym
      @name = "LoggerFacade::Plugins::Console"
    end

    def is_debug
      is_level_active(:debug)
    end

    def trace(logger, message)
      log(:trace, message, logger)
    end

    def debug(logger, message)
      log(:debug, message, logger)
    end

    def info(logger, message)
      log(:info, message, logger)
    end

    def warn(logger, message)
      log(:warn, message, logger)
    end

    def error(logger, message)
      log(:error, message, logger)
    end

    private

    def levels
      {
        trace: 0,
        debug: 1,
        info:  2,
        warn:  3,
        error: 4
      }
    end

    def is_level_active(log_level)
      levels[log_level] >= levels[level]
    end

    def message(level, msg, logger)
      msg = log_exception(msg) if msg.is_a? Exception

      config.message_format
        .gsub('%logger', logger.upcase)
        .gsub('%time', Time.now.utc.strftime(config.time_format))
        .gsub('%level', level.to_s.upcase)
        .gsub('%pid', Process.pid.to_s)
        .gsub('%msg', msg)
    end

    def log(log_level, message, logger)
      return unless is_level_active(log_level)

      Kernel.puts message(log_level, message, logger)
    end

    def log_exception(msg)
      "#{msg.message}\n#{(msg.backtrace || []).join("\n")}"
    end

  end

end
