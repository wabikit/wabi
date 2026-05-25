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
end
