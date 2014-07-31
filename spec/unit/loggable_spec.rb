require 'spec_helper'

describe LoggerFacade::Loggable do

  class X
    include LoggerFacade::Loggable

    def method
      # force lazy load
      log
    end

  end

  it('creates a logger with class name') do
    expect(LoggerFacade::Manager).to receive(:get_logger).with("X")
    X.new.method
  end

end
