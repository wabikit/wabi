# frozen_string_literal: true

require "json"
require "fileutils"

module Wabi
  # Manages config/wabi.lock.json in a user's Rails app.
  # Tracks installed components, versions, hashes, and registry origin.
  class Lockfile
    DEFAULT_REGISTRY = "https://wabi-docs.onrender.com/r"

    attr_reader :path, :registry, :components

    def self.load(path)
      data =
        if File.exist?(path)
          JSON.parse(File.read(path))
        else
          {}
        end
      new(path: path, data: data)
    end

    def initialize(path:, data: {})
      @path       = path
      @registry   = data["registry"]   || DEFAULT_REGISTRY
      @components = data["components"] || {}
    end

    # Normalizes a per-file lockfile entry to { hash:, content: }, tolerating
    # both the v0.9 object shape ({ "hash" =>, "content" => }) and the legacy
    # string-hash shape (content: nil → caller falls back to the prompt).
    def self.file_entry(raw)
      case raw
      when String then { hash: raw, content: nil }
      when Hash   then { hash: raw["hash"], content: raw["content"] }
      else             { hash: nil, content: nil }
      end
    end

    def record(name, version:, hash:, files: nil, js_dependencies: nil)
      entry = { "version" => version, "hash" => hash }
      entry["files"]           = files           if files
      entry["js_dependencies"] = js_dependencies if js_dependencies
      @components[name] = entry
    end

    def save
      FileUtils.mkdir_p(File.dirname(@path))
      File.write(@path, JSON.pretty_generate({
        "registry"   => @registry,
        "components" => @components,
      }))
    end
  end
end
