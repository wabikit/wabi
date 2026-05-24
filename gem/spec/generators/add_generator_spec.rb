# frozen_string_literal: true

require "rails/generators"
require "wabi/generators/add_generator"

RSpec.describe Wabi::Generators::AddGenerator do
  let(:destination) { File.expand_path("../../../tmp/add_target", __dir__) }
  let(:fake_registry) { File.expand_path("../../../tmp/fake_registry", __dir__) }

  before do
    FileUtils.rm_rf(destination)
    FileUtils.rm_rf(fake_registry)
    FileUtils.mkdir_p(File.join(destination, "config"))
    FileUtils.mkdir_p(fake_registry)

    # Seed lockfile pointing at our fake registry
    File.write(File.join(destination, "config/wabi.lock.json"), JSON.generate({
      "registry"   => "file://#{fake_registry}",
      "components" => {}
    }))

    # Seed fake registry JSON
    File.write(File.join(fake_registry, "button.json"), JSON.generate({
      "name" => "button",
      "version" => "0.1.0",
      "registry_dependencies" => [],
      "files" => [
        {
          "path" => "app/components/ui/button.rb",
          "type" => "ruby:phlex",
          "content" => "module UI\n  class Button < Wabi::Base\n  end\nend\n"
        }
      ]
    }))
  end

  after { FileUtils.rm_rf([destination, fake_registry]) }

  it "fetches the component JSON and writes the files" do
    described_class.start(["button"], destination_root: destination)
    file = File.join(destination, "app/components/ui/button.rb")
    expect(File.exist?(file)).to be true
    expect(File.read(file)).to include("class Button < Wabi::Base")
  end

  it "records the install in wabi.lock.json" do
    described_class.start(["button"], destination_root: destination)
    lock = JSON.parse(File.read(File.join(destination, "config/wabi.lock.json")))
    expect(lock["components"]["button"]["version"]).to eq("0.1.0")
    expect(lock["components"]["button"]["hash"]).to be_a(String)
  end

  it "resolves registry_dependencies recursively" do
    # Add a "card" component that depends on "button"
    File.write(File.join(fake_registry, "card.json"), JSON.generate({
      "name" => "card",
      "version" => "0.1.0",
      "registry_dependencies" => ["button"],
      "files" => [{
        "path" => "app/components/ui/card.rb",
        "type" => "ruby:phlex",
        "content" => "module UI\n  class Card < Wabi::Base; end\nend\n"
      }]
    }))

    described_class.start(["card"], destination_root: destination)
    expect(File.exist?(File.join(destination, "app/components/ui/card.rb"))).to be true
    expect(File.exist?(File.join(destination, "app/components/ui/button.rb"))).to be true
  end
end
