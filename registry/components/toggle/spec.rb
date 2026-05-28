# frozen_string_literal: true

require "wabi"
require_relative "toggle"

RSpec.describe Components::UI::Toggle do
  it "renders a <button> wired to the wabi--toggle controller" do
    output = described_class.new.call { "Bold" }
    expect(output).to start_with("<button")
    expect(output).to include('data-controller="wabi--toggle"')
    expect(output).to include("Bold")
  end

  it "defaults to data-state=off and pressed-value=false" do
    output = described_class.new.call { "Bold" }
    expect(output).to include('data-state="off"')
    expect(output).to include('data-wabi--toggle-pressed-value="false"')
  end

  it "flips to data-state=on when pressed: true" do
    output = described_class.new(pressed: true).call { "Bold" }
    expect(output).to include('data-state="on"')
    expect(output).to include('data-wabi--toggle-pressed-value="true"')
  end

  it "passes name through as a Stimulus value for hidden input wiring" do
    output = described_class.new(name: "format[bold]").call { "Bold" }
    expect(output).to include('data-wabi--toggle-name-value="format[bold]"')
  end

  it "carries disabled-value" do
    output = described_class.new(disabled: true).call { "Bold" }
    expect(output).to include('data-wabi--toggle-disabled-value="true"')
  end

  it "applies the default appearance variant classes" do
    output = described_class.new.call { "Bold" }
    expect(output).to include("bg-transparent")
    expect(output).to include("hover:bg-muted")
  end

  it "applies the outline appearance variant" do
    output = described_class.new(appearance: :outline).call { "Bold" }
    expect(output).to include("border")
    expect(output).to include("border-input")
  end

  it "applies the sm size variant" do
    output = described_class.new(size: :sm).call { "Bold" }
    expect(output).to include("h-9")
  end

  it "applies the lg size variant" do
    output = described_class.new(size: :lg).call { "Bold" }
    expect(output).to include("h-11")
  end
end
