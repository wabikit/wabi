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

  describe "new version, file unchanged on disk" do
    it "overwrites the file silently" do
      old_content = "class Button; end\n"
      new_content = "class Button\n  # v2\nend\n"
      seed_install(version: "0.1.0", content: old_content)
      seed_button(version: "0.2.0", content: new_content)

      capture_stdout do
        described_class.start(["button"], destination_root: destination)
      end

      expect(File.read(button_path)).to eq(new_content)
      lock = JSON.parse(File.read(File.join(destination, "config/wabi.lock.json")))
      expect(lock["components"]["button"]["version"]).to eq("0.2.0")
      expect(lock["components"]["button"]["files"]["app/components/ui/button.rb"])
        .to eq(Digest::SHA256.hexdigest(new_content))
    end
  end

  describe "new version, file edited on disk" do
    it "prompts and skips on 'n'" do
      old_content = "class Button; end\n"
      new_content = "class Button\n  # v2\nend\n"
      edited      = "class Button\n  # local edit\nend\n"

      seed_install(version: "0.1.0", content: old_content)
      File.write(button_path, edited)
      seed_button(version: "0.2.0", content: new_content)

      allow_any_instance_of(described_class).to receive(:prompt_conflict).and_return("n")

      capture_stdout do
        described_class.start(["button"], destination_root: destination)
      end

      expect(File.read(button_path)).to eq(edited)
    end

    it "prompts and overwrites on 'y'" do
      old_content = "class Button; end\n"
      new_content = "class Button\n  # v2\nend\n"
      edited      = "class Button\n  # local edit\nend\n"

      seed_install(version: "0.1.0", content: old_content)
      File.write(button_path, edited)
      seed_button(version: "0.2.0", content: new_content)

      allow_any_instance_of(described_class).to receive(:prompt_conflict).and_return("y")

      capture_stdout do
        described_class.start(["button"], destination_root: destination)
      end

      expect(File.read(button_path)).to eq(new_content)
    end
  end

  describe "options" do
    it "--force overwrites locally-edited files without prompting" do
      old_content = "class Button; end\n"
      new_content = "class Button\n  # v2\nend\n"
      seed_install(version: "0.1.0", content: old_content)
      File.write(button_path, "edited\n")
      seed_button(version: "0.2.0", content: new_content)

      capture_stdout do
        described_class.start(["button", "--force"], destination_root: destination)
      end

      expect(File.read(button_path)).to eq(new_content)
    end

    it "--dry-run writes nothing" do
      old_content = "class Button; end\n"
      new_content = "class Button\n  # v2\nend\n"
      seed_install(version: "0.1.0", content: old_content)
      seed_button(version: "0.2.0", content: new_content)

      capture_stdout do
        described_class.start(["button", "--dry-run"], destination_root: destination)
      end

      expect(File.read(button_path)).to eq(old_content)
      lock = JSON.parse(File.read(File.join(destination, "config/wabi.lock.json")))
      expect(lock["components"]["button"]["version"]).to eq("0.1.0")
    end
  end

  describe "legacy lockfile without files map" do
    it "treats every file as potentially edited and prompts" do
      old_content = "class Button; end\n"
      new_content = "class Button\n  # v2\nend\n"

      File.write(File.join(destination, "config/wabi.lock.json"), JSON.generate({
        "registry"   => "file://#{fake_registry}",
        "components" => {
          "button" => {
            "version" => "0.1.0",
            "hash"    => "agg",
          },
        },
      }))
      FileUtils.mkdir_p(File.dirname(button_path))
      File.write(button_path, old_content)
      seed_button(version: "0.2.0", content: new_content)

      prompts = 0
      allow_any_instance_of(described_class).to receive(:prompt_conflict) do
        prompts += 1
        "n"
      end

      capture_stdout do
        described_class.start(["button"], destination_root: destination)
      end

      expect(prompts).to eq(1)
    end
  end

  describe "js_dependencies diff" do
    it "prints only added/changed pins, not unchanged ones" do
      seed_install(version: "0.1.0", content: "class B; end\n")
      File.write(File.join(fake_registry, "button.json"), JSON.generate({
        "name" => "button",
        "version" => "0.2.0",
        "registry_dependencies" => [],
        "js_dependencies" => { "@zag-js/popover" => "1.41", "@new/pkg" => "2.0" },
        "files" => [{
          "path" => "app/components/ui/button.rb",
          "type" => "ruby:phlex",
          "content" => "class B; end\n",
        }],
      }))

      lock = JSON.parse(File.read(File.join(destination, "config/wabi.lock.json")))
      lock["components"]["button"]["js_dependencies"] = { "@zag-js/popover" => "1.41" }
      File.write(File.join(destination, "config/wabi.lock.json"), JSON.generate(lock))

      output = capture_stdout do
        described_class.start(["button"], destination_root: destination)
      end

      expect(output).to include("@new/pkg")
      expect(output).not_to include("@zag-js/popover")
    end
  end
end
