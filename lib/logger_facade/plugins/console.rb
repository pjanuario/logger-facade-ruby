require 'hashie'

module LoggerFacade::Plugins

  class Console < Base

    def initialize(config = {})
      super()

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

    protected

    def log(log_level, message, logger, metadata)
      return unless is_level_active(log_level)

      write message(log_level, message, logger, metadata)
    end

    private

    def message(level, msg, logger)
      msg = log_exception(msg) if msg.is_a? Exception

      config.message_format
        .gsub('%logger', logger.upcase)
        .gsub('%time', Time.now.utc.strftime(config.time_format))
        .gsub('%level', level.to_s.upcase)
        .gsub('%pid', Process.pid.to_s)
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
