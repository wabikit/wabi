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

      # All 8 v0.4 theme palettes. The docs tokens.css concatenates every
      # entry; the gem tokens.css only carries the default.
      THEME_SLUGS = %w[default stone rose blue green violet yellow orange].freeze

      def initialize(root:, gem_tokens_path: nil, docs_tokens_path: nil)
        @root = root
        # Tokens output paths are configurable so the spec can sandbox them.
        # Defaults point at the monorepo's gem template + docs Tailwind
        # source — every `bin/build` run regenerates both.
        @gem_tokens_path  = gem_tokens_path  || File.expand_path("../gem/templates/tokens.css", root)
        @docs_tokens_path = docs_tokens_path || File.expand_path("../docs/app/assets/tailwind/wabi/tokens.css", root)
      end

      def build
        FileUtils.mkdir_p(dist_dir)
        components = component_dirs.map { |dir| build_component(dir) }
        validate_all(components)
        write_index(components)
        build_themes
        components
      end

      def build_themes
        shared  = File.read(File.join(themes_dir, "_shared.css"))
        default = File.read(File.join(themes_dir, "default.css"))
        all     = THEME_SLUGS.map { |slug| File.read(File.join(themes_dir, "#{slug}.css")) }.join("\n")

        FileUtils.mkdir_p(File.dirname(@gem_tokens_path))
        FileUtils.mkdir_p(File.dirname(@docs_tokens_path))

        # Gem template: shared base + default theme only. wabi:install copies
        # this into user apps; users opt into other palettes via wabi:theme.
        File.write(@gem_tokens_path, [shared, default].join("\n"))

        # Docs site: shared base + all 8 themes concatenated. Lets the docs
        # theme picker live-switch between palettes on the same page.
        File.write(@docs_tokens_path, [shared, all].join("\n"))
      end

      private

      def dist_dir = File.join(@root, "dist/r")
      def components_dir = File.join(@root, "components")
      def themes_dir = File.join(@root, "themes")
      def schema_path = File.join(@root, "schema/component.v1.json")

      def component_dirs
        Dir[File.join(components_dir, "*")]
          .select { |p| File.directory?(p) }
          .reject { |p| File.basename(p).start_with?("_") }
          .sort
      end

      def build_component(dir)
        name = File.basename(dir)
        manifest = YAML.safe_load_file(File.join(dir, "manifest.yml"))

        files = Dir[File.join(dir, "*")]
          .reject { |p| File.basename(p) == "manifest.yml" || File.basename(p) == "spec.rb" }
          .sort
          .map { |path| file_entry(path) }

        # shared_files: entries in manifest.yml are paths relative to the
        # components/ root (e.g. "_shared/portal_registry.js"). They land in
        # the user's app under app/javascript/controllers/wabi/_shared/.
        shared = Array(manifest.delete("shared_files")).map do |rel|
          shared_path = File.join(components_dir, rel)
          shared_file_entry(shared_path, rel)
        end

        output = manifest.merge("files" => files + shared)
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

      # shared_file_entry maps a shared JS file to its destination in the user's
      # app. The relative path (e.g. "_shared/portal_registry.js") is appended
      # under app/javascript/controllers/wabi/ so the relative import in the
      # controller ("./_shared/portal_registry.js") resolves correctly.
      def shared_file_entry(abs_path, rel)
        ext  = File.extname(rel)
        type = EXTENSION_TO_TYPE[ext] || "unknown"
        {
          "path"    => "app/javascript/controllers/wabi/#{rel}",
          "type"    => type,
          "content" => File.read(abs_path),
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
