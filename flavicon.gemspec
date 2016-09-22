# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: flavicon 0.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "flavicon"
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Hamed Asghari"]
  s.date = "2016-09-22"
  s.description = "fetch favicon url by parsing html and falling back on /favicon.ico as default"
  s.email = "hasghari@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".ruby-gemset",
    ".ruby-version",
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "flavicon.gemspec",
    "lib/flavicon.rb",
    "lib/flavicon/finder.rb",
    "spec/fixtures/absolute.html",
    "spec/fixtures/missing.html",
    "spec/fixtures/multiple.html",
    "spec/fixtures/relative.html",
    "spec/flavicon/finder_spec.rb",
    "spec/flavicon_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/hasghari/flavicon"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "fetch favicon url for provided url"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.6"])
      s.add_development_dependency(%q<rspec>, ["~> 2.14"])
      s.add_development_dependency(%q<webmock>, ["~> 1.17"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0"])
      s.add_development_dependency(%q<pry>, ["~> 0"])
      s.add_development_dependency(%q<coveralls>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, ["~> 1.6"])
      s.add_dependency(%q<rspec>, ["~> 2.14"])
      s.add_dependency(%q<webmock>, ["~> 1.17"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_dependency(%q<simplecov>, ["~> 0"])
      s.add_dependency(%q<pry>, ["~> 0"])
      s.add_dependency(%q<coveralls>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, ["~> 1.6"])
    s.add_dependency(%q<rspec>, ["~> 2.14"])
    s.add_dependency(%q<webmock>, ["~> 1.17"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0"])
    s.add_dependency(%q<simplecov>, ["~> 0"])
    s.add_dependency(%q<pry>, ["~> 0"])
    s.add_dependency(%q<coveralls>, [">= 0"])
  end
end

