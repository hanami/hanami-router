# frozen_string_literal: true

require "rake"
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "hanami/devtools/rake_tasks"

RSpec::Core::RakeTask.new(:spec)

desc "Run all tests"
task test: :spec

RuboCop::RakeTask.new(:rubocop)
task lint: :rubocop

task default: %i[lint test]
