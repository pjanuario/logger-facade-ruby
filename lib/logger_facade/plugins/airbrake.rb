require 'airbrake'

module LoggerFacade::Plugins

  class Airbrake < Base

    attr_reader :environment

    def initialize(environment = nil)
      super("LoggerFacade::Plugins::Airbrake", { level: :error })
      @environment = environment.to_s
      set_default_airbrake_config
    end

    def configure(&block)
      ::Airbrake.configure do |config|
        yield config
      end
    end

    protected

    def log(log_level, message, logger, metadata)
      return unless is_level_active(log_level)

      notify(logger, message, metadata)
    end

    private

    def notify(logger, message, metadata)
      return unless valid_config

      if message.is_a? Exception
        notify_exception(message, logger)
      else
        notify_error_log(message, logger)
      end
    end

    def set_default_airbrake_config
      ::Airbrake.configure do |config|
        config.host    = nil
        config.port    = 80
        config.secure  = config.port == 443
        config.async   = true
        config.development_environments = %w(development test)
      end
    end

    def valid_config
      config = ::Airbrake.configuration
      config.api_key && config.host
    end

    def notify_error_log(message, logger)
      ::Airbrake.notify_or_ignore(
        :error_class      => "#{logger}::LogError",
        :error_message    => "#{logger}::LogError: #{message}",
        :backtrace        => $@,
        :cgi_data         => ENV.to_hash,
        :environment_name => environment
      )
    end

    def notify_exception(e, logger)
      ::Airbrake.notify_or_ignore(
        e,
        :backtrace        => $@,
        :cgi_data         => ENV.to_hash,
        :environment_name => environment
      )
    end

  end

end
