# frozen_string_literal: true
require "set"
require "wabi" # for Wabi::Error (defined in wabi.rb, not version.rb)

module Wabi
  # Walks the jsDelivr `+esm` import graph for one or more root packages and
  # rewrites cross-package CDN references (`/npm/<pkg>@<ver>/+esm`) to bare
  # specifiers (`<pkg>`), so every file can be served locally and resolved
  # through the importmap (Propshaft-digest-safe). Pure: HTTP is injected via
  # `fetcher`, a callable taking a URL string and returning the body string.
  class ZagVendor
    CDN = "https://cdn.jsdelivr.net"
    # /npm/<pkg>@<ver>/+esm — <pkg> may be scoped (@scope/name).
    REF = %r{/npm/((?:@[^/]+/)?[^/@]+)@([^/]+)/\+esm}

    Result = Struct.new(:files, :versions) # files: {pkg=>content}, versions: {pkg=>ver}

    def self.call(roots, fetcher:)
      new(fetcher).call(roots)
    end

    def initialize(fetcher)
      @fetcher = fetcher
    end

    # roots: [{ pkg: "@zag-js/dialog", ver: "1.41.0" }, ...]
    def call(roots)
      files = {}
      versions = {}
      seen = Set.new
      queue = roots.dup

      until queue.empty?
        item = queue.shift
        pkg = item[:pkg]
        ver = item[:ver]
        key = "#{pkg}@#{ver}"
        next if seen.include?(key)
        seen << key

        if versions[pkg] && versions[pkg] != ver
          raise Wabi::Error,
            "vendor: #{pkg} appears at two versions (#{versions[pkg]} and #{ver}); " \
            "a bare importmap pin can't carry two versions"
        end
        versions[pkg] = ver

        content = @fetcher.call("#{CDN}/npm/#{pkg}@#{ver}/+esm")
        files[pkg] = content.gsub(REF) do
          dep_pkg = Regexp.last_match(1)
          dep_ver = Regexp.last_match(2)
          queue << { pkg: dep_pkg, ver: dep_ver }
          dep_pkg
        end
      end

      Result.new(files, versions)
    end
  end
end
