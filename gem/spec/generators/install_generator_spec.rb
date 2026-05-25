# frozen_string_literal: true

require "rails/generators"
require "wabi/generators/install_generator"

RSpec.describe Wabi::Generators::InstallGenerator do
  let(:destination) { File.expand_path("../../../tmp/install_target", __dir__) }

  before do
    FileUtils.rm_rf(destination)
    FileUtils.mkdir_p(File.join(destination, "app/assets/tailwind"))
    FileUtils.mkdir_p(File.join(destination, "app/javascript/controllers"))
    File.write(File.join(destination, "app/assets/tailwind/application.css"), "@tailwind base;\n@tailwind components;\n@tailwind utilities;\n")
    File.write(File.join(destination, "tailwind.config.js"), "module.exports = { content: [] }")
  end

  after { FileUtils.rm_rf(destination) }

  it "copies tokens.css to app/assets/tailwind/wabi/" do
    described_class.start([], destination_root: destination)
    expect(File.exist?(File.join(destination, "app/assets/tailwind/wabi/tokens.css"))).to be true
  end

  it "copies theme_controller.js to app/javascript/controllers/wabi/" do
    described_class.start([], destination_root: destination)
    expect(File.exist?(File.join(destination, "app/javascript/controllers/wabi/theme_controller.js"))).to be true
  end

  it "creates an empty config/wabi.lock.json with default registry" do
    described_class.start([], destination_root: destination)
    lock = JSON.parse(File.read(File.join(destination, "config/wabi.lock.json")))
    expect(lock["registry"]).to eq("https://wabikit.dev/r")
    expect(lock["components"]).to eq({})
  end

  it "overwrites existing tokens.css when --force is passed" do
    target = File.join(destination, "app/assets/tailwind/wabi/tokens.css")
    FileUtils.mkdir_p(File.dirname(target))
    File.write(target, "/* OLD CONTENT */")

    described_class.start(["--force"], destination_root: destination)

    expect(File.read(target)).not_to include("OLD CONTENT")
    expect(File.read(target)).to include("--background") # real tokens content
  end

  it "preserves existing wabi.lock.json even when --force is passed" do
    lock_path = File.join(destination, "config/wabi.lock.json")
    FileUtils.mkdir_p(File.dirname(lock_path))
    File.write(lock_path, JSON.generate({
      "registry" => "http://custom.example/r",
      "components" => { "button" => { "version" => "0.1.0", "hash" => "abc" } }
    }))

    described_class.start(["--force"], destination_root: destination)

    lock = JSON.parse(File.read(lock_path))
    expect(lock["registry"]).to eq("http://custom.example/r")
    expect(lock["components"]).to have_key("button")
  end

  it "does NOT overwrite tokens.css without --force" do
    target = File.join(destination, "app/assets/tailwind/wabi/tokens.css")
    FileUtils.mkdir_p(File.dirname(target))
    File.write(target, "/* OLD CONTENT */")

    # Thor's copy_file with no force option will prompt or skip when file exists.
    # In test context with no TTY, it skips (the file_collision_behavior defaults to :skip).
    described_class.start([], destination_root: destination)

    expect(File.read(target)).to include("OLD CONTENT")
  end
end
