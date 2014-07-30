module LoggerFacade

  class Log

    attr_reader :plugins, :name

    def initialize(name, plugins)
      @name = name
      @plugins = plugins
    end

    def is_debug
      plugins.select { |p| p.is_debug }.size > 0
    end

    def trace(message)
      log(:trace, message)
    end

    def debug(message)
      log(:debug, message)
    end

    def info(message)
      log(:info, message)
    end

    def warn(message)
      log(:warn, message)
    end

    def error(message)
      log(:error, message)
    end

    private

    def log(level, message)
      plugins.each do |plugin|
        plugin.send(level, name, message)
      end
    end

  end

end
