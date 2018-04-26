
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hanami/router/version"

Gem::Specification.new do |spec|
  spec.name          = "hanami-router"
  spec.version       = Hanami::Router::VERSION
  spec.authors       = ["Luca Guidi"]
  spec.email         = ["me@lucaguidi.com"]
  spec.description   = "Rack compatible HTTP router for Ruby"
  spec.summary       = "Rack compatible HTTP router for Ruby and Hanami"
  spec.homepage      = "http://hanamirb.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files -- lib/* CHANGELOG.md LICENSE.md README.md hanami-router.gemspec`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.3.0"

  spec.add_dependency "rack",               "~> 2.0"
  spec.add_dependency "mustermann",         "~> 1.0"
  spec.add_dependency "mustermann-contrib", "~> 1.0"
  spec.add_dependency "hanami-utils",       "~> 2.0.alpha"
  spec.add_dependency "dry-inflector",      "~> 0.1"

  spec.add_development_dependency "bundler",   "~> 1.5"
  spec.add_development_dependency "rake",      "~> 11"
  spec.add_development_dependency "rack-test", "~> 0.6"
  spec.add_development_dependency "rspec",     "~> 3.7"
end
