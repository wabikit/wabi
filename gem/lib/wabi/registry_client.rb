# frozen_string_literal: true

require "net/http"
require "json"
require "fileutils"
require_relative "version"

module Wabi
  # Fetches component JSON from a registry URL with local caching.
  # Cache lives at ~/.cache/wabi/<gem_version>/<component>.json with 24h TTL
  # (configurable via WABI_CACHE_TTL env var, value in seconds).
  class RegistryClient
    DEFAULT_BASE_URL = "https://wabikit.dev/r"
    DEFAULT_TTL = 24 * 60 * 60 # 24h

    attr_reader :base_url

    def initialize(base_url: DEFAULT_BASE_URL)
      @base_url = base_url
    end

    def cache_dir
      File.expand_path("~/.cache/wabi/#{Wabi::VERSION}")
    end
  end
end
