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

    def trace(message, metadata = {})
      log(:trace, message, metadata)
    end

    def debug(message, metadata = {})
      log(:debug, message, metadata)
    end

    def info(message, metadata = {})
      log(:info, message, metadata)
    end

    def warn(message, metadata = {})
      log(:warn, message, metadata)
    end

    def error(message, metadata = {})
      log(:error, message, metadata)
    end

    private

    def log(level, message, metadata)
      plugins.each do |plugin|
        plugin.send(level, name, message, metadata: metadata)
      end
    end

  end

end
