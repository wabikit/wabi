require "rails_helper"
require "wabi/docs/indexer"
require "tmpdir"
require "fileutils"

RSpec.describe Wabi::Docs::Indexer do
  describe "::ROUTES_TO_INDEX" do
    it "covers 6 top-level + every ComponentsController::ALL detail page" do
      expect(described_class::ROUTES_TO_INDEX.size).to eq(6 + ComponentsController::ALL.size)
    end

    it "includes every component detail page from ComponentsController::ALL" do
      ComponentsController::ALL.each do |name|
        expect(described_class::ROUTES_TO_INDEX).to include("/docs/components/#{name}")
      end
    end

    it "excludes /preview" do
      expect(described_class::ROUTES_TO_INDEX).not_to include("/preview")
    end
  end

  describe ".crawl", type: :request do
    it "writes one .html file per route, all 200, mirroring the URL structure" do
      Dir.mktmpdir do |tmp|
        described_class.crawl(output_dir: tmp)
        files = Dir.glob(File.join(tmp, "**/*.html"))
        expect(files.size).to eq(described_class::ROUTES_TO_INDEX.size)
        files.each do |f|
          expect(File.read(f)).to include("<!doctype html>")
        end
      end
    end

    it "writes /docs/components/button to docs/components/button.html (nested), not flattened" do
      Dir.mktmpdir do |tmp|
        described_class.crawl(output_dir: tmp)
        expect(File.exist?(File.join(tmp, "docs/components/button.html"))).to be true
        expect(File.exist?(File.join(tmp, "docs_components_button.html"))).to be false
      end
    end

    it "writes / to index.html at root" do
      Dir.mktmpdir do |tmp|
        described_class.crawl(output_dir: tmp)
        expect(File.exist?(File.join(tmp, "index.html"))).to be true
      end
    end
  end
end
