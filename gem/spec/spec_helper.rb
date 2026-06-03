# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  enable_coverage :branch
  # Regression floors a few points below the measured baseline (line 92.3%,
  # branch 77.6% as of v0.14.2) so CI fails if coverage drops, without flagging
  # normal fluctuation. Raise these as coverage improves.
  minimum_coverage line: 88, branch: 72
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "wabi"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.warnings = true
end

require "webmock/rspec"
require "fakefs/safe"
WebMock.disable_net_connect!(allow_localhost: false)
