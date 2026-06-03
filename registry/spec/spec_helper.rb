# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  enable_coverage :branch
  # Regression floors a few points below the measured baseline (line 98.6%,
  # branch 60.5% as of v0.14.2) so CI fails if coverage drops. Branch coverage
  # is intrinsically lower here (lots of view conditionals); raise as it improves.
  minimum_coverage line: 95, branch: 55
end

$LOAD_PATH.unshift File.expand_path("../../gem/lib", __dir__)
require "wabi"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
