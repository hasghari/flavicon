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
  spec.homepage = 'https://github.com/hasghari/flavicon'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.0'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '~> 1.10'
end
