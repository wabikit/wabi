# frozen_string_literal: true
require "set"
require "cgi"
require "wabi" # for Wabi::Error (defined in wabi.rb, not version.rb)

module Wabi
  # Walks the jsDelivr `+esm` import graph for one or more root packages and
  # rewrites cross-package CDN references (`/npm/<pkg>@<ver>/+esm`) to bare
  # specifiers (`<pkg>`), so every file can be served locally and resolved
  # through the importmap (Propshaft-digest-safe). Pure: HTTP is injected via
  # `fetcher`, a callable taking a URL string and returning the body string.
  class ZagVendor
    CDN = "https://cdn.jsdelivr.net"
    # /npm/<pkg>@<ver>[/<subpath>]/+esm — <pkg> may be scoped (@scope/name).
    # jsDelivr references both the package root (`@ver/+esm`) and subpath exports
    # (`@ver/dom/+esm`, e.g. @floating-ui/utils/dom); group 3 captures the
    # optional subpath so those resolve to a distinct local module too.
    REF = %r{/npm/((?:@[^/]+/)?[^/@]+)@([^/]+?)((?:/[^/]+)*?)/\+esm}

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
      versions = {} # specifier => normalized version (first seen)
      queue = roots.map { |r| { spec: r[:pkg], sub: "", ver: normalize_version(r[:ver]) } }

      until queue.empty?
        item = queue.shift
        spec = item[:spec] # bare specifier incl. any subpath, e.g. "@floating-ui/utils/dom"
        pkg  = spec.sub(item[:sub], "") # package name without the subpath, for the fetch URL
        ver  = item[:ver]

        # Dedupe by SPECIFIER (package + subpath), not by URL: jsDelivr's real
        # graph references the same module both as a resolved pin (`@0.2.11`) and
        # as a range (`@%5E0.2.11`, i.e. URL-encoded `^0.2.11`). Those normalize
        # to the same version and the rewrite drops the version anyway (bare
        # specifier). Only genuinely-different versions (after normalizing the
        # range/encoding) are a real conflict a single bare importmap pin can't
        # carry.
        if versions.key?(spec)
          if versions[spec] != ver
            raise Wabi::Error,
              "vendor: #{spec} appears at two versions (#{versions[spec]} and #{ver}); " \
              "a bare importmap pin can't carry two versions"
          end
          next
        end
        versions[spec] = ver

        content = @fetcher.call("#{CDN}/npm/#{pkg}@#{ver}#{item[:sub]}/+esm")
        files[spec] = content.gsub(REF) do
          dep_pkg = Regexp.last_match(1)
          dep_ver = normalize_version(Regexp.last_match(2))
          dep_sub = Regexp.last_match(3).to_s # "" or "/dom"
          dep_spec = "#{dep_pkg}#{dep_sub}"
          queue << { spec: dep_spec, sub: dep_sub, ver: dep_ver }
          dep_spec
        end
      end

      Result.new(files, versions)
    end

    private

    # jsDelivr emits versions URL-encoded and sometimes as semver ranges
    # (`%5E0.2.11` → `^0.2.11`). Decode and strip leading range operators so a
    # range ref and a pin ref to the same resolved version compare equal. The
    # stripped exact version is also what we fetch (`@0.2.11/+esm`).
    def normalize_version(ver)
      CGI.unescape(ver.to_s).sub(/\A[\^~><= ]+/, "").strip
    end
  end
end
