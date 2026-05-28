# frozen_string_literal: true

require "rack/test"
require "fileutils"

module Wabi
  module Docs
    class Indexer
      include Rack::Test::Methods

      # Component slugs are sourced from ComponentsController::ALL so that adding a
      # component to the docs routing automatically extends the Pagefind crawl.
      ROUTES_TO_INDEX = [
        "/",
        "/docs/getting-started",
        "/docs/theming",
        "/docs/philosophy",
        "/docs/components",
        "/docs/themes",
        *ComponentsController::ALL.map { |n| "/docs/components/#{n}" },
      ].freeze

      def self.crawl(output_dir:)
        FileUtils.mkdir_p(output_dir)
        new.crawl(output_dir)
      end

      # A modern Chrome UA satisfies ApplicationController's `allow_browser versions: :modern` check.
      # HTTP_HOST=localhost satisfies ActionDispatch::HostAuthorization (Rack::Test defaults to example.org).
      CRAWL_HEADERS = {
        "HTTP_HOST"       => "localhost",
        "HTTP_USER_AGENT" =>
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " \
          "AppleWebKit/537.36 (KHTML, like Gecko) " \
          "Chrome/124.0.0.0 Safari/537.36",
      }.freeze

      def crawl(output_dir)
        ROUTES_TO_INDEX.each do |path|
          get path, {}, CRAWL_HEADERS
          raise "Crawl failed for #{path}: HTTP #{last_response.status}" unless last_response.ok?
          file_path = File.join(output_dir, sanitize(path))
          FileUtils.mkdir_p(File.dirname(file_path))
          File.write(file_path, last_response.body)
        end
      end

      private

      def app
        Rails.application
      end

      # Mirror the URL structure into the filesystem so Pagefind's URL inference
      # produces clickable links: "/docs/components/button" -> docs/components/
      # button.html (with intermediate dirs). PagefindUI strips the trailing
      # `.html` at result-display time. Underscores in slugs (dropdown_menu,
      # getting_started) are preserved.
      def sanitize(path)
        return "index.html" if path == "/"

        "#{path.sub(%r{\A/}, '')}.html"
      end
    end
  end
end
