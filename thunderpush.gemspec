# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'thunderpush/version'

Gem::Specification.new do |spec|
  spec.name          = 'thunderpush'
  spec.version       = ThunderPush::VERSION
  spec.authors       = ['Welington Sampaio']
  spec.email         = ['welington.sampaio@zaez.net']
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'multi_json', '~> 1.0'
  spec.add_dependency 'signature', '~> 0.1.6'
  spec.add_dependency 'httpclient', '~> 2.4'
  spec.add_dependency 'activesupport', '>= 4'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rspec',   '~> 3.1.0'
  spec.add_development_dependency 'pry',     '>= 0.9.12'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'growl'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'em-http-request', '~> 1.1.0'
  spec.add_development_dependency 'rake'
end
