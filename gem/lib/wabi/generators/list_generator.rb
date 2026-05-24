# frozen_string_literal: true

require "rails/generators"
require "wabi/lockfile"
require "wabi/registry_client"

module Wabi
  module Generators
    class ListGenerator < Rails::Generators::Base
      desc "List installed Wabi components and available components in the registry."

      def list
        lockfile = Wabi::Lockfile.load(File.join(destination_root, "config/wabi.lock.json"))
        installed_names = lockfile.components.keys

        client = Wabi::RegistryClient.new(base_url: lockfile.registry)
        catalog = client.fetch("index")["components"] || []

        say "\nRegistry: #{lockfile.registry}\n", :cyan
        catalog.each do |entry|
          name = entry["name"]
          marker = installed_names.include?(name) ? "[installed]" : "          "
          say format("  %s  %-20s  v%s", marker, name, entry["version"])
        end
      end
    end
  end
end
