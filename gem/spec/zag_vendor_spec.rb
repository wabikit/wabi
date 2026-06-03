# frozen_string_literal: true
require "wabi"
require "wabi/zag_vendor"

RSpec.describe Wabi::ZagVendor do
  # A fake jsDelivr: maps "<pkg>@<ver>" -> +esm body. Bodies reference deps by
  # the real `/npm/<pkg>@<ver>/+esm` form, exactly like jsDelivr output.
  def fetcher_for(graph)
    lambda do |url|
      key = url[%r{/npm/(.+)/\+esm}, 1]
      raise "unexpected fetch #{url}" unless graph.key?(key)
      graph.fetch(key)
    end
  end

  it "fetches a single dependency-free package and writes one file" do
    graph = { "@zag-js/toggle@1.41.0" => "export const x = 1;\n" }
    res = described_class.call([{ pkg: "@zag-js/toggle", ver: "1.41.0" }], fetcher: fetcher_for(graph))
    expect(res.files.keys).to eq(["@zag-js/toggle"])
    expect(res.files["@zag-js/toggle"]).to eq("export const x = 1;\n")
  end

  it "walks transitive deps and rewrites CDN refs to bare specifiers" do
    graph = {
      "@zag-js/dialog@1.41.0" => %(import{c}from"/npm/@zag-js/core@1.41.0/+esm";export{c};),
      "@zag-js/core@1.41.0"   => %(export const c = 2;),
    }
    res = described_class.call([{ pkg: "@zag-js/dialog", ver: "1.41.0" }], fetcher: fetcher_for(graph))
    expect(res.files.keys).to contain_exactly("@zag-js/dialog", "@zag-js/core")
    expect(res.files["@zag-js/dialog"]).to eq(%(import{c}from"@zag-js/core";export{c};))
  end

  it "fetches a shared (diamond) dep only once" do
    fetched = []
    graph = {
      "root@1.0.0" => %(import"/npm/a@1.0.0/+esm";import"/npm/b@1.0.0/+esm";),
      "a@1.0.0"    => %(import"/npm/shared@1.0.0/+esm";),
      "b@1.0.0"    => %(import"/npm/shared@1.0.0/+esm";),
      "shared@1.0.0" => %(export const s = 1;),
    }
    base = fetcher_for(graph)
    counting = ->(url) { fetched << url; base.call(url) }
    res = described_class.call([{ pkg: "root", ver: "1.0.0" }], fetcher: counting)
    expect(res.files.keys).to contain_exactly("root", "a", "b", "shared")
    expect(fetched.count { |u| u.include?("shared@1.0.0") }).to eq(1)
  end

  it "no output file references the CDN after rewrite (teeth)" do
    graph = {
      "@zag-js/dialog@1.41.0" => %(import"/npm/@zag-js/core@1.41.0/+esm";),
      "@zag-js/core@1.41.0"   => %(export const c = 1;),
    }
    res = described_class.call([{ pkg: "@zag-js/dialog", ver: "1.41.0" }], fetcher: fetcher_for(graph))
    res.files.each_value do |content|
      expect(content).not_to include("cdn.jsdelivr.net")
      expect(content).not_to include("/npm/")
    end
  end

  it "raises if a package appears at two genuinely different versions" do
    graph = {
      "root@1.0.0" => %(import"/npm/dep@1.0.0/+esm";import"/npm/dep@2.0.0/+esm";),
      "dep@1.0.0"  => "export const d=1;",
      "dep@2.0.0"  => "export const d=2;",
    }
    expect {
      described_class.call([{ pkg: "root", ver: "1.0.0" }], fetcher: fetcher_for(graph))
    }.to raise_error(Wabi::Error, /two versions|appears at/)
  end

  it "treats a range ref and a pin ref to the same version as one package" do
    # jsDelivr's real graph references the same dep both as `@%5E0.2.11`
    # (URL-encoded `^0.2.11`) and `@0.2.11`. These must NOT be a conflict.
    fetched = []
    graph = {
      "root@1.0.0"  => %(import"/npm/dep@%5E0.2.11/+esm";import"/npm/dep@0.2.11/+esm";),
      "dep@0.2.11"  => "export const d=1;",
    }
    base = fetcher_for(graph)
    counting = ->(url) { fetched << url; base.call(url) }
    res = described_class.call([{ pkg: "root", ver: "1.0.0" }], fetcher: counting)
    expect(res.files.keys).to contain_exactly("root", "dep")
    expect(res.versions["dep"]).to eq("0.2.11")            # normalized
    expect(fetched.count { |u| u.include?("/dep@") }).to eq(1) # fetched once, at the exact version
    expect(res.files["root"]).to eq(%(import"dep";import"dep";)) # both refs → bare specifier
  end

  it "vendors subpath exports (e.g. @floating-ui/utils/dom) as distinct modules" do
    # jsDelivr references subpath exports like `/npm/@scope/pkg@ver/dom/+esm`
    # (NOT the package root). These must be vendored + pinned as their own
    # specifier (`@scope/pkg/dom`), not collapsed to the root.
    graph = {
      "root@1.0.0"     => %(import"/npm/dep@0.2.11/dom/+esm";import"/npm/dep@0.2.11/+esm";),
      "dep@0.2.11/dom" => %(export const sub=1;),
      "dep@0.2.11"     => %(export const root=1;),
    }
    res = described_class.call([{ pkg: "root", ver: "1.0.0" }], fetcher: fetcher_for(graph))
    expect(res.files.keys).to contain_exactly("root", "dep", "dep/dom")
    expect(res.files["root"]).to eq(%(import"dep/dom";import"dep";))
  end
end
