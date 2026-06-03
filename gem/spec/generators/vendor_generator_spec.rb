# frozen_string_literal: true
require "rails/generators"
require "webmock/rspec"
require "wabi/generators/vendor_generator"

RSpec.describe Wabi::Generators::VendorGenerator do
  let(:destination) { File.expand_path("../../../tmp/vendor_target", __dir__) }
  let(:importmap)   { File.join(destination, "config/importmap.rb") }

  def stub_esm(pkg, ver, body)
    stub_request(:get, "https://cdn.jsdelivr.net/npm/#{pkg}@#{ver}/+esm").to_return(status: 200, body: body)
  end

  before do
    FileUtils.rm_rf(destination)
    FileUtils.mkdir_p(File.join(destination, "config"))
    File.write(importmap, <<~RUBY)
      pin "application"
      pin "@zag-js/dialog", to: "https://cdn.jsdelivr.net/npm/@zag-js/dialog@1.41.0/+esm"
      pin "@zag-js/vanilla", to: "https://cdn.jsdelivr.net/npm/@zag-js/vanilla@1.41.0/+esm"
    RUBY
    stub_esm("@zag-js/dialog", "1.41.0", %(import"/npm/@zag-js/core@1.41.0/+esm";export const d=1;))
    stub_esm("@zag-js/vanilla", "1.41.0", %(export const v=1;))
    stub_esm("@zag-js/core", "1.41.0", %(export const c=1;))
  end

  after { FileUtils.rm_rf(destination) }

  it "downloads every graph package into vendor/javascript and pins them locally" do
    described_class.start([], destination_root: destination)

    %w[@zag-js/dialog.js @zag-js/vanilla.js @zag-js/core.js].each do |rel|
      f = File.join(destination, "vendor/javascript", rel)
      expect(File.exist?(f)).to be(true), "expected #{rel} to be vendored"
      expect(File.read(f)).not_to include("cdn.jsdelivr.net") # teeth
    end

    map = File.read(importmap)
    expect(map).to include(%(pin "@zag-js/dialog", to: "@zag-js/dialog.js"))
    expect(map).to include(%(pin "@zag-js/core", to: "@zag-js/core.js"))   # transitive dep pinned
    expect(map).not_to include("cdn.jsdelivr.net/npm/@zag-js/dialog")       # CDN pin replaced
    expect(map).to include(%(pin "application"))                            # untouched
  end

  it "is idempotent (no duplicate pins on re-run)" do
    described_class.start([], destination_root: destination)
    described_class.start([], destination_root: destination)
    expect(File.read(importmap).scan(%(pin "@zag-js/dialog",)).size).to eq(1)
  end
end
