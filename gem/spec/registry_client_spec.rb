# frozen_string_literal: true

require "wabi/registry_client"

RSpec.describe Wabi::RegistryClient do
  describe ".new" do
    it "defaults to https://wabikit.dev/r" do
      client = described_class.new
      expect(client.base_url).to eq("https://wabikit.dev/r")
    end

    it "accepts a custom base url" do
      client = described_class.new(base_url: "http://localhost:3000/r")
      expect(client.base_url).to eq("http://localhost:3000/r")
    end

    it "exposes a cache directory path scoped by gem version" do
      client = described_class.new
      expected = File.expand_path("~/.cache/wabi/#{Wabi::VERSION}")
      expect(client.cache_dir).to eq(expected)
    end
  end
end
