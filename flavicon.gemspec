# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flavicon/version'

Gem::Specification.new do |spec|
  spec.name = 'flavicon'
  spec.version = Flavicon::VERSION
  spec.authors = ['Hamed Asghari']
  spec.email = ['hasghari@gmail.com']

  spec.summary = 'fetch favicon url for provided url'
  spec.description = 'fetch favicon url by parsing html and falling back on /favicon.ico as default'
  spec.homepage = 'http://github.com/hasghari/flavicon'
  spec.license = 'MIT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '~> 1.10'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry', '~> 0'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.33'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'webmock', '~> 3.6'
end
