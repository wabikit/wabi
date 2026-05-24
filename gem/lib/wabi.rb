# frozen_string_literal: true

require_relative "wabi/version"
require_relative "wabi/base"
require_relative "wabi/class_merge"
require_relative "wabi/variants"
require_relative "wabi/registry_client"
require_relative "wabi/lockfile"

module Wabi
  class Error < StandardError; end
end

# Generators are only loaded under Rails (which triggers them via convention)
if defined?(Rails::Generators)
  require_relative "wabi/generators/install_generator"
  require_relative "wabi/generators/add_generator"
  require_relative "wabi/generators/list_generator"
  require_relative "wabi/generators/registry_generator"
end
