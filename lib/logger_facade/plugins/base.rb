module LoggerFacade::Plugins

  class Base

    attr_reader :config, :level, :name

    def initialize(name, config = nil)
      @config = Hashie::Mash.new(config)
      @level = (@config.level || :debug).to_sym
      @name = name
    end

    def is_debug
      is_level_active(:debug)
    end

    def trace(logger, message, metadata: {})
      log(:trace, message, logger, metadata)
    end

    def debug(logger, message, metadata: {})
      log(:debug, message, logger, metadata)
    end

    def info(logger, message, metadata: {})
      log(:info, message, logger, metadata)
    end

    def warn(logger, message, metadata: {})
      log(:warn, message, logger, metadata)
    end

    def error(logger, message, metadata: {})
      log(:error, message, logger, metadata)
    end

    protected

    def log(severity, message, logger, metadata)
      # do nothing by default
    end

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

  end

end
