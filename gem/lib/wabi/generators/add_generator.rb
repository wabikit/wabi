# frozen_string_literal: true

require "rails/generators"
require "digest"
require "wabi/registry_client"
require "wabi/lockfile"

module Wabi
  module Generators
    class AddGenerator < Rails::Generators::Base
      argument :components, type: :array, banner: "component_name [component_name ...]"

      desc "Add one or more Wabi components to this app."

      def add_components
        @js_deps_to_pin = {}
        lockfile # eager-init via accessor
        components.each { |name| install_component(name) }
        lockfile.save
        print_js_pin_instructions
      end

      private

      def lockfile
        @lockfile ||= Wabi::Lockfile.load(File.join(destination_root, "config/wabi.lock.json"))
      end

      def client
        @client ||= Wabi::RegistryClient.new(base_url: lockfile.registry)
      end

      def install_component(name)
        return if lockfile.components.key?(name)
        say "  fetching  #{name}", :cyan
        data = client.fetch(name)

        Array(data["registry_dependencies"]).each { |dep| install_component(dep) }

        data["files"].each do |file|
          target = File.join(destination_root, file["path"])
          FileUtils.mkdir_p(File.dirname(target))
          File.write(target, file["content"])
          say "  create    #{file["path"]}", :green
        end

        (data["js_dependencies"] || {}).each { |pkg, ver| @js_deps_to_pin[pkg] = ver }

        hash = Digest::SHA256.hexdigest(JSON.generate(data["files"]))
        lockfile.record(name, version: data["version"], hash: hash)
      end

      def print_js_pin_instructions
        return if @js_deps_to_pin.empty?
        say "\n  This component requires JS packages. Pin them with:", :yellow
        @js_deps_to_pin.each_key do |pkg|
          say "    bin/importmap pin #{pkg}"
        end
      end
    end
  end
end
