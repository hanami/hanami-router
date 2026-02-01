# frozen_string_literal: true

source "https://rubygems.org"

gemspec

eval_gemfile "Gemfile.devtools"

unless ENV["CI"]
  gem "byebug", platforms: :mri
  gem "yard"
  gem "yard-junk"
end

if ENV["RACK_MATRIX_VALUE"]
  gem "rack", ENV["RACK_MATRIX_VALUE"]
end

gem "ostruct" # Remove once we drop support for Rack 2
gem "hanami-devtools", github: "hanami/devtools", branch: "main"
gem "webrick"

group :test do
  gem "rack-test", "~> 2.0"
  gem "rspec", "~> 3.8"
end
