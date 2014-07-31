lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require './lib/logger_facade/version'

Gem::Specification.new do |spec|
  spec.name          = 'logger_facade'
  spec.version       = LoggerFacade::VERSION
  spec.authors       = ["Pedro Januário"]
  spec.email         = ["prnjanuario@gmail.com"]
  spec.description   = %q{Simple class library to work as logger facade.
                        This simple logger facade allows you to hook plugins to execute logging.}
  spec.summary       = %q{Logger Facade library}
  spec.homepage      = "https://github.com/pjanuario/logger-facade-ruby"
  spec.metadata      = {
    "source_code" => "https://github.com/pjanuario/logger-facade-ruby",
    "issue_tracker" => "https://github.com/pjanuario/logger-facade-ruby/issues"
  }
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'simplecov', '~> 0.9'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0.3'
  spec.add_development_dependency 'bump', '~> 0.5'

  spec.add_dependency 'hashie', '~> 3.2'
  spec.add_dependency 'airbrake', '~> 4.0'
  # sucker punch is used to use airbrake async
  spec.add_dependency 'sucker_punch', '~> 1.1'
end
