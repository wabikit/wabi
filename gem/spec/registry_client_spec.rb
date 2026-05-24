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

  describe "#fetch" do
    let(:json_body) { '{"name":"button","version":"0.1.0","files":[]}' }

    around do |example|
      FakeFS.with_fresh { example.run }
    end

    it "fetches JSON from the registry and returns the parsed hash" do
      stub_request(:get, "https://wabikit.dev/r/button.json")
        .to_return(status: 200, body: json_body, headers: { "Content-Type" => "application/json" })

      client = described_class.new
      result = client.fetch("button")
      expect(result).to include("name" => "button", "version" => "0.1.0")
    end

    it "caches the response to disk on first fetch" do
      stub_request(:get, "https://wabikit.dev/r/button.json")
        .to_return(status: 200, body: json_body)

      client = described_class.new
      client.fetch("button")

      cached_path = File.join(client.cache_dir, "button.json")
      expect(File.exist?(cached_path)).to be true
      expect(File.read(cached_path)).to eq(json_body)
    end

    it "returns cached value on second fetch without hitting network" do
      stub_request(:get, "https://wabikit.dev/r/button.json")
        .to_return(status: 200, body: json_body)

      client = described_class.new
      client.fetch("button")

      WebMock.reset_executed_requests!
      result = client.fetch("button")
      expect(result["name"]).to eq("button")
      expect(WebMock).not_to have_requested(:get, "https://wabikit.dev/r/button.json")
    end

    it "raises Wabi::Error on non-200 response" do
      stub_request(:get, "https://wabikit.dev/r/nonexistent.json")
        .to_return(status: 404, body: "Not Found")

      client = described_class.new
      expect { client.fetch("nonexistent") }.to raise_error(Wabi::Error, /404/)
    end
  end
end
