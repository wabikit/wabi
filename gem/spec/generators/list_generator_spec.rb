# frozen_string_literal: true

require "rails/generators"
require "wabi/generators/list_generator"

RSpec.describe Wabi::Generators::ListGenerator do
  let(:destination) { File.expand_path("../../../tmp/list_target", __dir__) }
  let(:fake_registry) { File.expand_path("../../../tmp/fake_list_registry", __dir__) }

  before do
    FileUtils.rm_rf([destination, fake_registry])
    FileUtils.mkdir_p(File.join(destination, "config"))
    FileUtils.mkdir_p(fake_registry)

    File.write(File.join(destination, "config/wabi.lock.json"), JSON.generate({
      "registry"   => "file://#{fake_registry}",
      "components" => { "button" => { "version" => "0.1.0", "hash" => "abc" } }
    }))

    File.write(File.join(fake_registry, "index.json"), JSON.generate({
      "components" => [
        { "name" => "button", "version" => "0.1.0" },
        { "name" => "card",   "version" => "0.1.0" }
      ]
    }))
  end

  after { FileUtils.rm_rf([destination, fake_registry]) }

  it "prints installed and available components" do
    output = capture(:stdout) { described_class.start([], destination_root: destination) }
    expect(output).to include("button")
    expect(output).to include("card")
    expect(output).to match(/installed/i)
  end

  def capture(stream)
    captured = StringIO.new
    original = $stdout
    $stdout = captured
    yield
    captured.string
  ensure
    $stdout = original
  end
end
