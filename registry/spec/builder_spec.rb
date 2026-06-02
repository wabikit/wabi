# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "builder"
require "fileutils"
require "json"

RSpec.describe Wabi::Registry::Builder do
  let(:tmp) { File.expand_path("../tmp_build", __dir__) }
  let(:sandbox_gem)  { File.join(tmp, "sandbox_gem_tokens.css") }
  let(:sandbox_docs) { File.join(tmp, "sandbox_docs_tokens.css") }

  # Helper: every Builder in this suite uses sandboxed tokens paths so the
  # tests never clobber the real gem/templates/tokens.css or the docs site's
  # canonical tokens.css.
  def new_builder(**overrides)
    described_class.new(
      root: tmp,
      gem_tokens_path:  sandbox_gem,
      docs_tokens_path: sandbox_docs,
      **overrides,
    )
  end

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

    # Minimal themes/ skeleton so the post-Sprint-6 build_themes step
    # doesn't blow up when these older #build specs run without setting
    # up their own theme files. The #build_themes describe block below
    # overrides this with realistic fixtures.
    FileUtils.mkdir_p(File.join(tmp, "themes"))
    File.write(File.join(tmp, "themes/_shared.css"), "/* shared stub */\n")
    %w[default stone rose blue green violet yellow orange].each do |slug|
      File.write(File.join(tmp, "themes/#{slug}.css"), "/* #{slug} stub */\n")
    end
  end

  after { FileUtils.rm_rf(tmp) }

  describe "#build" do
    it "writes a per-component JSON to dist/r/" do
      new_builder.build
      output = JSON.parse(File.read(File.join(tmp, "dist/r/button.json")))
      expect(output["name"]).to eq("button")
      expect(output["version"]).to eq("0.1.0")
      expect(output["files"]).to be_an(Array)
      expect(output["files"].first["path"]).to eq("app/components/ui/button.rb")
      expect(output["files"].first["content"]).to include("class Button < Wabi::Base")
    end

    it "writes an index.json listing all components" do
      new_builder.build
      index = JSON.parse(File.read(File.join(tmp, "dist/r/index.json")))
      expect(index["components"]).to include(
        a_hash_including("name" => "button", "version" => "0.1.0")
      )
    end

    it "validates output against the v1 schema" do
      new_builder.build
      # If validation fails inside #build, it raises. Reaching here = validation passed.
      expect(File.exist?(File.join(tmp, "dist/r/button.json"))).to be true
    end
  end

  describe "#build_component" do
    it "excludes *.test.js files from a component's dist (they must not ship to users)" do
      comp = File.join(tmp, "components", "widget")
      FileUtils.mkdir_p(comp)
      FileUtils.mkdir_p(File.join(tmp, "dist/r"))
      File.write(File.join(comp, "manifest.yml"), { "name" => "widget", "type" => "registry:display" }.to_yaml)
      File.write(File.join(comp, "widget.rb"), "# widget\n")
      File.write(File.join(comp, "widget_controller.js"), "// controller\n")
      File.write(File.join(comp, "widget_controller.test.js"), "// THIS MUST NOT SHIP\n")

      builder = new_builder
      output = builder.send(:build_component, comp)

      paths = output["files"].map { |f| f["path"] }
      expect(paths).to include("app/components/ui/widget.rb", "app/javascript/controllers/wabi/widget_controller.js")
      expect(paths).not_to include("widget_controller.test.js")
      expect(output["files"].map { |f| f["content"] }.join).not_to include("MUST NOT SHIP")
    end
  end

  describe "#build_themes" do
    let(:slugs) { %w[default stone rose blue green violet yellow orange] }

    before do
      # Overwrite the stubs from the outer `before` with realistic fixtures.
      File.write(File.join(tmp, "themes/_shared.css"),
                 "@custom-variant dark (&:where([data-mode=\"dark\"]));\n@theme inline { --color-primary: hsl(var(--primary)); }")
      # Default ships `:root, [data-theme="default"]`; every other theme
      # ships only `[data-theme="<slug>"]` (no :root). Mirrors the real
      # registry/themes/ files -- a regression spec below asserts only ONE
      # :root in the docs output, which is the bug that broke light-mode
      # theme switching on first try.
      slugs.each do |slug|
        selector = (slug == "default") ? ":root, [data-theme=\"#{slug}\"]" : "[data-theme=\"#{slug}\"]"
        File.write(File.join(tmp, "themes/#{slug}.css"),
                   "#{selector} { --primary: 0 0% 50%; }\n" \
                   "[data-theme=\"#{slug}\"][data-mode=\"dark\"] { --primary: 0 0% 50%; }")
      end
    end

    it "writes the gem tokens.css combining _shared.css + default.css only" do
      new_builder.build_themes
      output = File.read(sandbox_gem)
      expect(output).to include("@custom-variant dark")
      expect(output).to include("@theme inline")
      expect(output).to include('[data-theme="default"]')
      expect(output).to include('[data-theme="default"][data-mode="dark"]')
      # Default-only artifact must NOT carry the other 7 themes:
      expect(output).not_to include('[data-theme="yellow"]')
      expect(output).not_to include('[data-theme="violet"]')
    end

    it "writes the docs tokens.css combining _shared.css + all 8 themes" do
      new_builder.build_themes
      output = File.read(sandbox_docs)
      expect(output).to include("@custom-variant dark")
      expect(output).to include("@theme inline")
      slugs.each do |slug|
        expect(output).to include(%([data-theme="#{slug}"]))
        expect(output).to include(%([data-theme="#{slug}"][data-mode="dark"]))
      end
    end

    it "build runs build_themes as part of the full pipeline" do
      new_builder.build
      expect(File.exist?(sandbox_gem)).to be true
      expect(File.exist?(sandbox_docs)).to be true
    end

    it "docs tokens.css contains exactly ONE :root block (no clobber)" do
      # Regression: the first pass had every theme ship `:root, [data-theme=
      # "<slug>"]`, so :root was redefined 8 times. :root and [data-theme=X]
      # have equal specificity (0,1,0); later :root in source order clobbered
      # earlier [data-theme=X] rules in light mode (dark blocks had higher
      # specificity (0,2,0) and so escaped). Only default theme owns :root.
      new_builder.build_themes
      output = File.read(sandbox_docs)
      root_blocks = output.scan(/^:root[,\s{]/).length
      expect(root_blocks).to eq(1)
    end
  end
end
