# frozen_string_literal: true

require "rails/generators"
require "wabi/lockfile"

module Wabi
  module Generators
    class RegistryGenerator < Rails::Generators::Base
      argument :url, type: :string, banner: "registry_url"

      desc "Set the registry URL for this project."

      def update_registry
        path = File.join(destination_root, "config/wabi.lock.json")
        lockfile = Wabi::Lockfile.load(path)
        # Lockfile doesn't currently expose a registry setter; bypass via instance_var.
        lockfile.instance_variable_set(:@registry, url)
        lockfile.save
        say "  registry → #{url}", :green
      end
    end
  end
end
