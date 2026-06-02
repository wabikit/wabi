# frozen_string_literal: true

require "wabi/lockfile"
require "tmpdir"

RSpec.describe Wabi::Lockfile do
  let(:path) { "/tmp/wabi.lock.json" }

  around { |ex| FakeFS.with_fresh { ex.run } }

  describe ".load" do
    it "returns an empty lockfile when the file does not exist" do
      lf = described_class.load(path)
      expect(lf.components).to eq({})
      expect(lf.registry).to eq("https://wabi-docs.onrender.com/r")
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

  describe "#record_files" do
    let(:tmpdir) { Dir.mktmpdir }
    let(:real_path) { File.join(tmpdir, "wabi.lock.json") }

    after { FileUtils.rm_rf(tmpdir) }

    it "stores a per-file SHA256 map under the component entry" do
      lockfile = described_class.load(real_path)
      lockfile.record(
        "button",
        version: "0.1.0",
        hash: "agg",
        files: { "app/components/ui/button.rb" => "abc123" },
      )
      lockfile.save

      reloaded = described_class.load(real_path)
      entry = reloaded.components["button"]
      expect(entry["files"]).to eq("app/components/ui/button.rb" => "abc123")
    end

    it "tolerates legacy entries without a files map" do
      File.write(real_path, JSON.generate({
        "registry"   => "https://example/r",
        "components" => { "button" => { "version" => "0.1.0", "hash" => "agg" } },
      }))
      lockfile = described_class.load(real_path)
      expect(lockfile.components["button"]["files"]).to be_nil
    end
  end

  describe ".file_entry" do
    it "normalizes a new-shape object entry" do
      e = Wabi::Lockfile.file_entry({ "hash" => "abc", "content" => "x = 1\n" })
      expect(e[:hash]).to eq("abc")
      expect(e[:content]).to eq("x = 1\n")
    end

    it "normalizes a legacy string-hash entry to content: nil" do
      e = Wabi::Lockfile.file_entry("abc")
      expect(e[:hash]).to eq("abc")
      expect(e[:content]).to be_nil
    end

    it "tolerates a nil/garbage entry" do
      expect(Wabi::Lockfile.file_entry(nil)).to eq({ hash: nil, content: nil })
    end
  end
end
