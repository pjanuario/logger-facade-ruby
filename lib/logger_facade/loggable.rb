module LoggerFacade

  module Loggable

    def log
      @log ||= LoggerFacade::Manager.get_logger(self.class.name)
    end

  end

end
