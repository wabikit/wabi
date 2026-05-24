# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "builder"
require "fileutils"
require "json"

RSpec.describe Wabi::Registry::Builder do
  let(:tmp) { File.expand_path("../tmp_build", __dir__) }

  before do
    FileUtils.rm_rf(tmp)
    FileUtils.mkdir_p(File.join(tmp, "components/button"))
    FileUtils.mkdir_p(File.join(tmp, "schema"))

    # Copy real schema into the tmp registry
    FileUtils.cp(
      File.expand_path("../schema/component.v1.json", __dir__),
      File.join(tmp, "schema/component.v1.json")
    )

    File.write(File.join(tmp, "components/button/manifest.yml"), <<~YAML)
      name: button
      version: 0.1.0
      type: registry:form
      description: A clickable button.
      registry_dependencies: []
      ruby_dependencies: []
      js_dependencies: {}
      tailwind:
        extend: {}
      metadata:
        a11y: WCAG-AA
        rails_min: "8.0"
        phlex_min: "1.11"
    YAML

    File.write(File.join(tmp, "components/button/button.rb"), <<~RUBY)
      module UI
        class Button < Wabi::Base
        end
      end
    RUBY
  end

  after { FileUtils.rm_rf(tmp) }

  describe "#build" do
    it "writes a per-component JSON to dist/r/" do
      described_class.new(root: tmp).build
      output = JSON.parse(File.read(File.join(tmp, "dist/r/button.json")))
      expect(output["name"]).to eq("button")
      expect(output["version"]).to eq("0.1.0")
      expect(output["files"]).to be_an(Array)
      expect(output["files"].first["path"]).to eq("app/components/ui/button.rb")
      expect(output["files"].first["content"]).to include("class Button < Wabi::Base")
    end

    it "writes an index.json listing all components" do
      described_class.new(root: tmp).build
      index = JSON.parse(File.read(File.join(tmp, "dist/r/index.json")))
      expect(index["components"]).to include(
        a_hash_including("name" => "button", "version" => "0.1.0")
      )
    end

    it "validates output against the v1 schema" do
      described_class.new(root: tmp).build
      # If validation fails inside #build, it raises. Reaching here = validation passed.
      expect(File.exist?(File.join(tmp, "dist/r/button.json"))).to be true
    end
  end
end
