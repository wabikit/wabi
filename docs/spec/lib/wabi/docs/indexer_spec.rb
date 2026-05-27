require "rails_helper"
require "wabi/docs/indexer"
require "tmpdir"
require "fileutils"

RSpec.describe Wabi::Docs::Indexer do
  describe "::ROUTES_TO_INDEX" do
    it "covers 26 routes (excluding /preview)" do
      expect(described_class::ROUTES_TO_INDEX.size).to eq(26)
    end

    it "includes all 20 component detail pages" do
      ComponentsController::ALL.each do |name|
        expect(described_class::ROUTES_TO_INDEX).to include("/docs/components/#{name}")
      end
    end

    it "excludes /preview" do
      expect(described_class::ROUTES_TO_INDEX).not_to include("/preview")
    end
  end

  describe ".crawl", type: :request do
    it "writes one .html file per route, all 200" do
      Dir.mktmpdir do |tmp|
        described_class.crawl(output_dir: tmp)
        files = Dir.glob(File.join(tmp, "*.html"))
        expect(files.size).to eq(described_class::ROUTES_TO_INDEX.size)
        files.each do |f|
          expect(File.read(f)).to include("<!doctype html>")
        end
      end
    end
  end
end
