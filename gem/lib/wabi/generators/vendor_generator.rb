# frozen_string_literal: true
require "rails/generators"
require "net/http"
require "uri"
require "fileutils"
require "wabi/zag_vendor"

module Wabi
  module Generators
    class VendorGenerator < Rails::Generators::Base
      argument :packages, type: :array, default: [],
               banner: "[@scope/pkg ...]  (default: all jsDelivr +esm pins in config/importmap.rb)"

      desc "Download Zag's +esm graph into vendor/javascript and pin it locally (offline / strict-CSP)."

      def vendor
        roots = resolve_roots
        if roots.empty?
          say "  No jsDelivr +esm pins found in config/importmap.rb (nothing to vendor).", :yellow
          return
        end

        result = Wabi::ZagVendor.call(roots, fetcher: method(:http_get))

        result.files.each do |pkg, content|
          target = File.join(destination_root, "vendor/javascript", "#{pkg}.js")
          FileUtils.mkdir_p(File.dirname(target))
          File.write(target, content)
          say "  vendor    vendor/javascript/#{pkg}.js", :green
        end

        rewrite_importmap(result.files.keys)
        say "\n  Vendored #{result.files.size} package(s). config/importmap.rb now points at local copies.", :green
      end

      private

      IMPORTMAP = "config/importmap.rb"
      # pin "<name>", to: "<jsDelivr +esm url>"
      CDN_PIN = /^\s*pin\s+"(?<name>[^"]+)",\s*to:\s*"(?<url>https:\/\/cdn\.jsdelivr\.net\/npm\/[^"]+\/\+esm)"/

      def importmap_path
        File.join(destination_root, IMPORTMAP)
      end

      def resolve_roots
        return [] unless File.exist?(importmap_path)
        content = File.read(importmap_path)
        pins = content.each_line.filter_map do |line|
          next unless (m = line.match(CDN_PIN))
          ref = m[:url].match(Wabi::ZagVendor::REF)
          next unless ref
          { name: m[:name], pkg: ref[1], ver: ref[2] }
        end
        return pins.map { |p| { pkg: p[:pkg], ver: p[:ver] } } if packages.empty?
        packages.map do |name|
          found = pins.find { |p| p[:pkg] == name }
          { pkg: name, ver: found ? found[:ver] : "1.41.0" }
        end
      end

      # For every vendored package, ensure `pin "<pkg>", to: "<pkg>.js" # vendored by wabi`.
      # Replace an existing pin for that pkg (CDN or vendored); insert if absent.
      def rewrite_importmap(pkgs)
        content = File.exist?(importmap_path) ? File.read(importmap_path) : ""
        pkgs.each do |pkg|
          new_line = %(pin "#{pkg}", to: "#{pkg}.js" # vendored by wabi)
          existing = /^\s*pin\s+"#{Regexp.escape(pkg)}",.*$/
          if content =~ existing
            content = content.sub(existing, new_line)
          else
            content = content.rstrip + "\n" + new_line + "\n"
          end
        end
        File.write(importmap_path, content)
      end

      # Net::HTTP.get_response does NOT follow redirects; jsDelivr may 3xx.
      def http_get(url, limit = 5)
        raise Wabi::Error, "vendor: too many redirects for #{url}" if limit <= 0
        res = Net::HTTP.get_response(URI.parse(url))
        case res
        when Net::HTTPSuccess      then res.body.dup.force_encoding("UTF-8")
        when Net::HTTPRedirection  then http_get(URI.join(url, res["location"]).to_s, limit - 1)
        else raise Wabi::Error, "vendor: failed to fetch #{url}: HTTP #{res.code}"
        end
      end
    end
  end
end
