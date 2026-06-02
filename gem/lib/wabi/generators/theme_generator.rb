# frozen_string_literal: true

require "rails/generators"
require "wabi/lockfile"
require "net/http"
require "uri"

module Wabi
  module Generators
    class ThemeGenerator < Rails::Generators::Base
      argument :slug, type: :string, banner: "theme_slug"

      desc "Switch to a different Wabi theme palette (default, slate, stone, zinc, rose, blue, green, violet)."

      def fetch_and_write
        lockfile = Wabi::Lockfile.load(File.join(destination_root, "config/wabi.lock.json"))
        base = lockfile.registry  # e.g. https://wabi-docs.onrender.com/r OR file:///abs/path

        shared = fetch("#{base}/themes/_shared.css", label: "_shared")
        body   = fetch("#{base}/themes/#{slug}.css", label: slug)

        target = File.join(destination_root, "app/assets/tailwind/wabi/tokens.css")
        FileUtils.mkdir_p(File.dirname(target))
        File.write(target, [shared, body].join("\n"))

        say "  theme  → #{slug}", :green
        say "  wrote  app/assets/tailwind/wabi/tokens.css", :green
        say "         Run `bin/rails tailwindcss:build` to compile the new palette.", :cyan
      end

      private

      def fetch(url_or_path, label:)
        if url_or_path.start_with?("file://")
          path = url_or_path.sub("file://", "")
          raise Wabi::Error, "Theme #{label} not found at #{path}" unless File.exist?(path)
          File.read(path)
        else
          uri = URI.parse(url_or_path)
          response = Net::HTTP.get_response(uri)
          raise Wabi::Error, "Theme #{label} not found at #{url_or_path}: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)
          response.body
        end
      end
    end
  end
end
