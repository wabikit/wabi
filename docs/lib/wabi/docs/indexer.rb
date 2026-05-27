# frozen_string_literal: true

require "rack/test"
require "fileutils"

module Wabi
  module Docs
    class Indexer
      include Rack::Test::Methods

      ROUTES_TO_INDEX = [
        "/",
        "/docs/getting-started",
        "/docs/theming",
        "/docs/philosophy",
        "/docs/components",
        "/docs/themes",
        *%w[
          button input textarea label card badge separator alert avatar
          checkbox switch select dialog drawer tooltip popover
          dropdown_menu toast tabs accordion
        ].map { |n| "/docs/components/#{n}" },
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
          File.write(File.join(output_dir, sanitize(path)), last_response.body)
        end
      end

      private

      def app
        Rails.application
      end

      def sanitize(path)
        slug = path == "/" ? "index" : path.tr("/", "_").sub(/\A_/, "")
        "#{slug}.html"
      end
    end
  end
end
