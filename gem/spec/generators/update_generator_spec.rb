# frozen_string_literal: true

require "rails/generators"
require "wabi/generators/update_generator"

RSpec.describe Wabi::Generators::UpdateGenerator do
  let(:destination)   { File.expand_path("../../../tmp/update_target", __dir__) }
  let(:fake_registry) { File.expand_path("../../../tmp/fake_registry_update", __dir__) }
  let(:button_path)   { File.join(destination, "app/components/ui/button.rb") }

  def seed_button(version:, content:)
    File.write(File.join(fake_registry, "button.json"), JSON.generate({
      "name" => "button",
      "version" => version,
      "registry_dependencies" => [],
      "files" => [{
        "path" => "app/components/ui/button.rb",
        "type" => "ruby:phlex",
        "content" => content,
      }],
    }))
  end

  def seed_install(version:, content:)
    File.write(File.join(destination, "config/wabi.lock.json"), JSON.generate({
      "registry"   => "file://#{fake_registry}",
      "components" => {
        "button" => {
          "version" => version,
          "hash"    => Digest::SHA256.hexdigest(JSON.generate([{
            "path" => "app/components/ui/button.rb",
            "type" => "ruby:phlex",
            "content" => content,
          }])),
          "files"   => { "app/components/ui/button.rb" => Digest::SHA256.hexdigest(content) },
        },
      },
    }))
    FileUtils.mkdir_p(File.dirname(button_path))
    File.write(button_path, content)
  end

  before do
    FileUtils.rm_rf(destination)
    FileUtils.rm_rf(fake_registry)
    FileUtils.mkdir_p(File.join(destination, "config"))
    FileUtils.mkdir_p(fake_registry)
  end

  after { FileUtils.rm_rf([destination, fake_registry]) }

  def capture_stdout
    captured = StringIO.new
    original = $stdout
    $stdout = captured
    yield
    captured.string
  ensure
    $stdout = original
  end

  describe "up-to-date component" do
    it "writes nothing and reports up-to-date" do
      content = "class Button; end\n"
      seed_button(version: "0.1.0", content: content)
      seed_install(version: "0.1.0", content: content)
      original_mtime = File.mtime(button_path)

      output = capture_stdout do
        described_class.start(["button"], destination_root: destination)
      end

      expect(output).to match(/up-to-date|already at/i)
      expect(File.mtime(button_path)).to eq(original_mtime)
    end
  end
end
