# frozen_string_literal: true

require "rails/generators"
require "wabi/generators/registry_generator"

RSpec.describe Wabi::Generators::RegistryGenerator do
  let(:destination) { File.expand_path("../../../tmp/registry_target", __dir__) }

  before do
    FileUtils.rm_rf(destination)
    FileUtils.mkdir_p(File.join(destination, "config"))
    File.write(File.join(destination, "config/wabi.lock.json"), JSON.generate({
      "registry"   => "https://wabikit.dev/r",
      "components" => {}
    }))
  end

  after { FileUtils.rm_rf(destination) }

  it "updates the registry URL in wabi.lock.json" do
    described_class.start(["http://localhost:3000/r"], destination_root: destination)
    lock = JSON.parse(File.read(File.join(destination, "config/wabi.lock.json")))
    expect(lock["registry"]).to eq("http://localhost:3000/r")
  end
end
