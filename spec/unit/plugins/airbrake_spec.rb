require 'spec_helper'

describe LoggerFacade::Plugins::Airbrake do

  subject { described_class.new(:test) }

  before :each do

    subject.configure do |c|
      c.host = "host.test"
      c.api_key = "key.test"
    end

  end

  describe('#is_debug') do

    it('returns false') do
      expect(subject.is_debug).to be false
    end

  end

  describe('#configure') do

    it('overrides Airbrake configurations') do

      subject.configure do |config|
        config.api_key = "key"
      end

      expect(::Airbrake.configuration.api_key).to eq("key")
    end

  end

  %w(trace debug info warn).each do |level|

    context("logging in #{level} level") do

      it("doesn't notify") do
        message = "call with message"
        expect(::Airbrake).not_to receive(:notify_or_ignore)
        subject.send(level.to_sym, "name", message)
      end

    end

  end

  context("logging in error level") do

    context('with message') do

      it("notify") do
        message = "call with message"
        expect(::Airbrake).to receive(:notify_or_ignore)
           .with(hash_including(
             :error_class     => "NAME::LogError",
             :error_message   => "NAME::LogError: #{message}",
             :backtrace       => anything,
             :cgi_data        => anything,
             :environment_name=> "test"
           )) { nil }
        subject.error("NAME", message)
      end
    end

    context('with exception') do

      it("notify") do
        e = Exception.new 'test notify'
        expect(::Airbrake).to receive(:notify_or_ignore)
           .with(e, hash_including(
             :backtrace       => anything,
             :cgi_data        => anything,
             :environment_name=> "test"
           )) { nil }
        subject.error("NAME", e)
      end

    end

  end

end
