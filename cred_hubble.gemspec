
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cred_hubble/version'

Gem::Specification.new do |spec|
  spec.name          = 'cred_hubble'
  spec.version       = CredHubble::VERSION
  spec.authors       = ['Tim Downey']
  spec.email         = ['tim@downey.io']

  spec.summary       = 'Unofficial Ruby Client for interacting with the ' \
                       'Cloud Foundry CredHub credential store'
  spec.homepage      = 'https://github.com/tcdowney/cred_hubble'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.1'

  spec.add_runtime_dependency 'faraday', ['>= 0.13', '< 1.0']
  spec.add_runtime_dependency 'virtus', ['>= 1.0', '< 2.0']
  spec.add_runtime_dependency 'addressable', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'gem-release'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'webmock', '~> 3.0'
  spec.add_development_dependency 'yard'
end
