if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

$:.push '.'

require 'rspec'
require 'pry'
require 'logger_facade'

Dir['spec/support/**/*.rb'].each &method(:require)

RSpec.configure do |c|
  c.around(:each) do |example|
    Timeout::timeout(2) {
      example.run
    }
  end
end

module TimeTestHelper
  def with_mock_time(t = 0)
    mc = class <<Time; self; end
    mc.send :alias_method, :old_now, :now
    mc.send :define_method, :now do
      at(t)
    end
    yield
  ensure
    mc.send :alias_method, :now, :old_now
  end
end

module LevelTestHelper
  def next_level(lev)
    levels = {
      trace: 0,
      debug: 1,
      info:  2,
      warn:  3,
      error: 4
    }

    val = levels[lev.to_sym]
    levels.select { |k,v| v > val }.keys.first
  end
end
