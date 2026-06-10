# frozen_string_literal: true

# Load phlex-rails before anything else: it gives Phlex components render_in /
# the Rails integration. Without this require, apps that only `bundle add wabi`
# get a Phlex::HTML with no Rails support and `render Components::UI::X` fails
# with "must implement #to_partial_path". Guarded because phlex/rails needs
# ActiveSupport (absent in the bare gem test env).
require "phlex/rails" if defined?(Rails)

require_relative "wabi/version"
require_relative "wabi/base"
require_relative "wabi/class_merge"
require_relative "wabi/variants"
require_relative "wabi/registry_client"
require_relative "wabi/lockfile"
require_relative "wabi/turbo_stream_extensions"

module Wabi
  class Error < StandardError; end
end

# Generators are only loaded under Rails (which triggers them via convention)
if defined?(Rails::Generators)
  require_relative "wabi/generators/install_generator"
  require_relative "wabi/generators/add_generator"
  require_relative "wabi/generators/update_generator"
  require_relative "wabi/generators/list_generator"
  require_relative "wabi/generators/registry_generator"
  require_relative "wabi/generators/theme_generator"
  require_relative "wabi/generators/vendor_generator"
end
