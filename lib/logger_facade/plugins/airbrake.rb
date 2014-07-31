require 'airbrake'

module LoggerFacade::Plugins

  class Airbrake

    attr_reader :name

    def initialize(config = {})
      @name = "LoggerFacade::Plugins::Airbrake"

      ::Airbrake.configure do |config|
        config.host    = nil
        config.port    = 80
        config.secure  = config.port == 443
        config.async   = true
        config.development_environments = %w(development test)
      end
    end

    def configure(&block)
      ::Airbrake.configure do |config|
        yield config
      end
    end

    def is_debug
      false
    end

    def trace(logger, message)
      # do nothing
    end

    def debug(logger, message)
      # do nothing
    end

    def info(logger, message)
      # do nothing
    end

    def warn(logger, message)
      # do nothing
    end

    def error(logger, message)
      return unless valid_config

      if message.is_a? Exception
        notify_exception(message, logger)
      else
        notify_error_log(message, logger)
      end
    end

    private

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
      )
    end

    def notify_exception(e, logger)
      ::Airbrake.notify_or_ignore(
        e,
        :backtrace     => $@,
        :cgi_data      => ENV.to_hash,
      )
    end

  end

end
