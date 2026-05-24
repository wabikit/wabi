# frozen_string_literal: true

require "yaml"
require "json"
require "fileutils"
require "json_schemer"

module Wabi
  module Registry
    # Reads components/<name>/{manifest.yml, <name>.rb, *.rb, *.js} and emits
    # dist/r/<name>.json (each file embedded as content string).
    class Builder
      EXTENSION_TO_TYPE = {
        ".rb" => "ruby:phlex",
        ".js" => "javascript:stimulus",
      }.freeze

      def initialize(root:)
        @root = root
      end

      def build
        FileUtils.mkdir_p(dist_dir)
        components = component_dirs.map { |dir| build_component(dir) }
        validate_all(components)
        write_index(components)
        components
      end

      private

      def dist_dir = File.join(@root, "dist/r")
      def components_dir = File.join(@root, "components")
      def schema_path = File.join(@root, "schema/component.v1.json")

      def component_dirs
        Dir[File.join(components_dir, "*")].select { |p| File.directory?(p) }.sort
      end

      def build_component(dir)
        name = File.basename(dir)
        manifest = YAML.safe_load_file(File.join(dir, "manifest.yml"))

        files = Dir[File.join(dir, "*")]
          .reject { |p| File.basename(p) == "manifest.yml" || File.basename(p) == "spec.rb" }
          .sort
          .map { |path| file_entry(path) }

        output = manifest.merge("files" => files)
        File.write(File.join(dist_dir, "#{name}.json"), JSON.pretty_generate(output))
        output
      end

      def file_entry(path)
        ext = File.extname(path)
        type = EXTENSION_TO_TYPE[ext] || "unknown"
        basename = File.basename(path)

        rails_path =
          case type
          when "ruby:phlex"          then "app/components/ui/#{basename}"
          when "javascript:stimulus" then "app/javascript/controllers/wabi/#{basename}"
          else basename
          end

        {
          "path"    => rails_path,
          "type"    => type,
          "content" => File.read(path),
        }
      end

      def validate_all(components)
        schemer = JSONSchemer.schema(JSON.parse(File.read(schema_path)))
        components.each do |c|
          errors = schemer.validate(c).to_a
          next if errors.empty?
          raise "Schema validation failed for #{c["name"]}: #{errors.map { |e| e["error"] }.join(", ")}"
        end
      end

      def write_index(components)
        index = {
          "schema_version" => "v1",
          "components" => components.map { |c| { "name" => c["name"], "version" => c["version"] } }
        }
        File.write(File.join(dist_dir, "index.json"), JSON.pretty_generate(index))
      end
    end
  end
end
