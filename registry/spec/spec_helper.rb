# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../gem/lib", __dir__)
require "wabi"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
