# frozen_string_literal: true

require "wabi"
require_relative "separator"

RSpec.describe Components::UI::Separator do
  it "renders horizontal by default" do
    output = described_class.new.call
    expect(output).to include("h-[1px]")
    expect(output).to include("w-full")
  end

  it "renders vertical when specified" do
    output = described_class.new(orientation: :vertical).call
    expect(output).to include("h-full")
    expect(output).to include("w-[1px]")
  end

  it "emits <hr> (native role=separator) with aria-orientation when not decorative" do
    output = described_class.new(decorative: false).call
    # <hr> carries role=separator natively — no explicit role attribute needed
    expect(output).to include("<hr")
    expect(output).not_to include('role="separator"')
    expect(output).to include('aria-orientation="horizontal"')
  end

  it "emits <hr> with aria-orientation=vertical when not decorative and vertical" do
    output = described_class.new(decorative: false, orientation: :vertical).call
    expect(output).to include("<hr")
    expect(output).to include('aria-orientation="vertical"')
  end

  it "applies role=none when decorative (default)" do
    output = described_class.new.call
    expect(output).to include('role="none"')
  end
end
