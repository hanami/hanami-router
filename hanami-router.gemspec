# frozen_string_literal: true

# This file is synced from hanakai-rb/repo-sync. To update it, edit repo-sync.yml.

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hanami/router/version"

Gem::Specification.new do |spec|
  spec.name          = "hanami-router"
  spec.authors       = ["Hanakai team"]
  spec.email         = ["info@hanakai.org"]
  spec.license       = "MIT"
  spec.version       = Hanami::Router::VERSION.dup

  spec.summary       = "Rack compatible HTTP router for Ruby and Hanami"
  spec.description   = spec.summary
  spec.homepage      = "https://hanamirb.org"
  spec.files         = Dir["CHANGELOG.md", "LICENSE", "README.md", "hanami-router.gemspec", "lib/**/*"]
  spec.bindir        = "exe"
  spec.executables   = Dir["exe/*"].map { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.extra_rdoc_files = ["README.md", "CHANGELOG.md", "LICENSE"]

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["changelog_uri"]     = "https://github.com/hanami/hanami-router/blob/main/CHANGELOG.md"
  spec.metadata["source_code_uri"]   = "https://github.com/hanami/hanami-router"
  spec.metadata["bug_tracker_uri"]   = "https://github.com/hanami/hanami-router/issues"
  spec.metadata["funding_uri"]       = "https://github.com/sponsors/hanami"

  spec.required_ruby_version = ">= 3.2"

  spec.add_runtime_dependency "rack", ">= 2.2.16"
  spec.add_runtime_dependency "mustermann", "~> 3.0"
  spec.add_runtime_dependency "mustermann-contrib", "~> 3.0"
  spec.add_runtime_dependency "csv", "~> 3.3"
end

