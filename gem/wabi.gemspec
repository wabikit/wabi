# frozen_string_literal: true

require_relative "lib/wabi/version"

Gem::Specification.new do |spec|
  spec.name          = "wabi"
  spec.version       = Wabi::VERSION
  spec.authors       = ["Oscar Ortega"]
  spec.email         = ["dev@cosmaneura.com"]

  spec.summary       = "Beautifully imperfect components for Rails."
  spec.description   = "An OSS UI component library for Rails 8 — Phlex-native, " \
                       "Tailwind-themed, accessible, with 'you own the code' philosophy."
  spec.homepage      = "https://wabikit.dev"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 4.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/wabikit/wabi"
  spec.metadata["bug_tracker_uri"] = "https://github.com/wabikit/wabi/issues"
  spec.metadata["changelog_uri"]   = "https://github.com/wabikit/wabi/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*", "templates/**/*", "LICENSE", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "phlex-rails", "~> 2.4"
  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "zeitwerk", "~> 2.8"

  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "fakefs", "~> 3.2"
  spec.add_development_dependency "webmock", "~> 3.26"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "simplecov", "~> 0.22"
end
