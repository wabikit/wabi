# frozen_string_literal: true

require "wabi/lockfile"

RSpec.describe Wabi::Lockfile do
  let(:path) { "/tmp/wabi.lock.json" }

  around { |ex| FakeFS.with_fresh { ex.run } }

  describe ".load" do
    it "returns an empty lockfile when the file does not exist" do
      lf = described_class.load(path)
      expect(lf.components).to eq({})
      expect(lf.registry).to eq("https://wabikit.dev/r")
    end

    it "reads existing JSON content" do
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, JSON.generate({
        "registry" => "http://localhost:3000/r",
        "components" => {
          "button" => { "version" => "0.1.0", "hash" => "abc123" }
        }
      }))

      lf = described_class.load(path)
      expect(lf.registry).to eq("http://localhost:3000/r")
      expect(lf.components["button"]).to eq({ "version" => "0.1.0", "hash" => "abc123" })
    end
  end

  describe "#record" do
    it "stores a component entry" do
      lf = described_class.load(path)
      lf.record("button", version: "0.1.0", hash: "abc")
      expect(lf.components["button"]).to eq({ "version" => "0.1.0", "hash" => "abc" })
    end
  end

  describe "#save" do
    it "writes JSON to disk" do
      lf = described_class.load(path)
      lf.record("button", version: "0.1.0", hash: "abc")
      lf.save

      contents = JSON.parse(File.read(path))
      expect(contents["components"]["button"]["version"]).to eq("0.1.0")
    end
  end
end
