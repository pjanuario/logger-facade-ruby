module LoggerFacade

  class Manager

    def self.use(plugin)
      fail 'Invalid plugin argument' unless plugin

      registered_plugins << plugin
    end

    def self.plugins
      registered_plugins.map(&:name)
    end

    def self.clear_plugins
      @@plugins = []
    end

    def self.get_logger(name)
      LoggerFacade::Log.new(name, registered_plugins)
    end

    private

    def self.registered_plugins
      @@plugins ||= []
    end

  end

end
