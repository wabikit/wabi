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

        files_map = {}
        data["files"].each do |file|
          target = File.join(destination_root, file["path"])
          FileUtils.mkdir_p(File.dirname(target))
          File.write(target, file["content"])
          files_map[file["path"]] = {
            "hash"    => Digest::SHA256.hexdigest(file["content"]),
            "content" => file["content"],
          }
          say "  create    #{file["path"]}", :green
        end

        (data["js_dependencies"] || {}).each { |pkg, ver| @js_deps_to_pin[pkg] = ver }

        hash = Digest::SHA256.hexdigest(JSON.generate(data["files"]))
        lockfile.record(name, version: data["version"], hash: hash, files: files_map,
                        js_dependencies: data["js_dependencies"])
      end

      def print_js_pin_instructions
        return if @js_deps_to_pin.empty?
        say "\n  This component requires JS packages. Add these pins to config/importmap.rb:", :yellow
        @js_deps_to_pin.each do |pkg, version|
          v = version.to_s.sub(/\A[~^]/, "")
          v = "1.0.0" if v.empty?
          say %(    pin "#{pkg}", to: "https://cdn.jsdelivr.net/npm/#{pkg}@#{v}/+esm")
        end
        say "\n  NOTE: `bin/importmap pin <pkg>` is NOT recommended for packages with submodule"
        say "  imports (like @zag-js/*) — it only downloads the entry file, leaving relative"
        say "  imports unresolved. The `+esm` endpoint above ships a single bundle with all"
        say "  transitive deps resolved to absolute URLs.", :yellow
      end
    end
  end
end
