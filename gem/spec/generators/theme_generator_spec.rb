# frozen_string_literal: true

require "spec_helper"
require "rails/generators"
require "wabi/generators/theme_generator"
require "fileutils"
require "json"

RSpec.describe Wabi::Generators::ThemeGenerator do
  let(:destination)   { File.expand_path("../../../tmp/theme_target", __dir__) }
  let(:fake_registry) { File.expand_path("../../../tmp/fake_theme_registry", __dir__) }

  before do
    FileUtils.rm_rf([destination, fake_registry])
    FileUtils.mkdir_p(File.join(destination, "config"))
    FileUtils.mkdir_p(File.join(destination, "app/assets/tailwind/wabi"))
    FileUtils.mkdir_p(File.join(fake_registry, "themes"))

    File.write(File.join(destination, "config/wabi.lock.json"), JSON.generate({
      "registry"   => "file://#{fake_registry}",
      "components" => {},
    }))

    File.write(File.join(fake_registry, "themes/_shared.css"),
               "@custom-variant dark (&:where([data-mode=\"dark\"]));\n@theme inline { --color-primary: hsl(var(--primary)); }")
    File.write(File.join(fake_registry, "themes/rose.css"),
               %([data-theme="rose"] { --primary: 346 77% 50%; }))
  end

  after { FileUtils.rm_rf([destination, fake_registry]) }

  it "writes the concatenated _shared + slug to tokens.css" do
    described_class.start(["rose"], destination_root: destination)

    tokens = File.read(File.join(destination, "app/assets/tailwind/wabi/tokens.css"))
    expect(tokens).to include("@custom-variant dark")
    expect(tokens).to include("@theme inline")
    expect(tokens).to include('[data-theme="rose"]')
    expect(tokens).to include("--primary: 346 77% 50%")
  end

  it "raises when the slug doesn't exist in the registry" do
    expect { described_class.start(["bogus"], destination_root: destination) }
      .to raise_error(Wabi::Error, /Theme bogus not found/)
  end
end
