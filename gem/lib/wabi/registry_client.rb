# frozen_string_literal: true

require "net/http"
require "json"
require "fileutils"
require "uri"
require_relative "version"

module Wabi
  class RegistryClient
    DEFAULT_BASE_URL = "https://wabikit.dev/r"
    DEFAULT_TTL = 24 * 60 * 60

    attr_reader :base_url

    def initialize(base_url: DEFAULT_BASE_URL)
      @base_url = base_url
      @ttl = Integer(ENV.fetch("WABI_CACHE_TTL", DEFAULT_TTL))
    end

    def cache_dir
      File.expand_path("~/.cache/wabi/#{Wabi::VERSION}")
    end

    def fetch(component_name)
      cached = read_cache(component_name)
      return JSON.parse(cached) if cached

      uri = URI.parse("#{@base_url}/#{component_name}.json")
      response = Net::HTTP.get_response(uri)

      unless response.is_a?(Net::HTTPSuccess)
        raise Wabi::Error, "Failed to fetch #{component_name}: HTTP #{response.code}"
      end

      body = response.body
      write_cache(component_name, body)
      JSON.parse(body)
    end

    private

    def cache_path(name)
      File.join(cache_dir, "#{name}.json")
    end

    def read_cache(name)
      path = cache_path(name)
      return nil unless File.exist?(path)
      return nil if (Time.now - File.mtime(path)) > @ttl
      File.read(path)
    end

    def write_cache(name, body)
      FileUtils.mkdir_p(cache_dir)
      File.write(cache_path(name), body)
    end
  end
end
