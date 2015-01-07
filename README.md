[![Build Status](https://travis-ci.org/pjanuario/logger-facade-ruby.svg?branch=master)](https://travis-ci.org/pjanuario/logger-facade-ruby)
[![Code Climate](https://codeclimate.com/github/pjanuario/logger-facade-ruby.png)](https://codeclimate.com/github/pjanuario/logger-facade-ruby)
[![Coverage](http://img.shields.io/codeclimate/coverage/github/pjanuario/logger-facade-ruby.svg)](https://codeclimate.com/github/pjanuario/logger-facade-ruby)
[![Dependency Status](https://gemnasium.com/pjanuario/logger-facade-ruby.svg)](https://gemnasium.com/pjanuario/logger-facade-ruby)

# Logger Facade Ruby

[![version](https://badge.fury.io/rb/logger_facade.svg)](https://rubygems.org/gems/logger_facade)


Simple class library to work as logger facade.

This simple logger facade allows you to hook plugins to execute logging.

## Installation

Add this line to your application's Gemfile:

    gem ' logger_facade'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install logger_facade

## How to use it

Install it:

```
gem install logger_facade
```

Set up plugins

```ruby
require 'logger_facade'

# configuration is optional in console plugin
plugin = LoggerFacade::Plugins::Console.new(config);

# hook plugin/s
LoggerFacade::Manager.use(plugin)

# obtain class logger
log = LoggerFacade::Manager.get_logger("Log Name")

# log
log.debug("something to log")
log.info("something to log in info")

# log exception directly
log.error(Exception.new("some caught exception"))
```

**NOTE**: Console plugin uses check [strftime](http://www.ruby-doc.org/core-2.1.2/Time.html#method-i-strftime) formats.

### With Sinatra

```ruby
require 'logger_facade'
require 'logger_facade/middleware/rack'

plugin = LoggerFacade::Plugins::Console.new({ level: Settings.logging.console.level })
LoggerFacade::Manager.use(plugin)

set :logging, nil
use LoggerFacade::Middleware::Rack
```

## Available plugins
* [Console](#loggerfacadepluginsconsole)
* [Airbrake](#loggerfacadepluginsairbrake)
* Elasticsearch (Will be developed soon)

** Do you need some other plugin?**

Feel free to create one and get in touch with me, that i will add it to this list.

## LoggerFacade::Manager Contract

```ruby
# register a plugin on logger
LoggerFacade::Manager.use(plugin)
# retrieve the list of plugin names
LoggerFacade::Manager.plugins()
# clean  up the list of registered plugins
LoggerFacade::Manager.clearPlugins()
# retrieve a logger with the specified name
log = LoggerFacade::Manager.getLogger("Log Name")
```

## LoggerFacade::Log Contract

```ruby
log.isDebug() # return if in debug or trace level
log.trace("trace something")
log.debug("debug something")
log.info("info something")
log.warn("warn something")
log.error("error something")
log.error(Exception.new('some caught exception'))
```

## LoggerFacade::Plugins

The plugins must follow this contract:

```
# plugin name
#name

#isDebug
#trace
#debug
#info
#warn
#error
```

## Plugins available

### LoggerFacade::Plugins::Console

```ruby
# this is default config for Console plugin
config = {
  level: :info,
  time_format: '%y-%M-%d %H:%M:%S',
  message_format: '%time | %level | %logger - %msg'
}

# configuration is optional in console plugin
plugin = LoggerFacade::Plugins::Console.new(config);
LoggerFacade::Manager.use(plugin)
```

### LoggerFacade::Plugins::Airbrake

```ruby
env = 'production'
plugin = LoggerFacade::Plugins::Airbrake.new(env)
plugin.configure do |config|
  config.api_key = "airbrake.api_key"
  config.host = "airbrake.host"
  config.port = "airbrake.port"
  config.secure = config.port == 443
end
LoggerFacade::Manager.use(plugin)
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Bump versioning

We use [bump gem](https://github.com/gregorym/bump) to control gem versioning.
Use --tag to generate commit and tag for each version.

Bump Patch version

    $ bump patch --tag

Bump Minor version

    $ bump minor --tag

Bump Major version

    $ bump major --tag

## Running Specs

    $ rspec

## Coverage Report

    $ open ./coverage/index.html

## Credits
Shout out to @pjanuario.
