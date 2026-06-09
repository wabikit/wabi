# frozen_string_literal: true

require "wabi"
require_relative "progress"

RSpec.describe Components::UI::Progress do
  it "renders a progressbar with aria value attributes" do
    output = described_class.new(value: 40).call
    expect(output).to include('role="progressbar"')
    expect(output).to include('aria-valuenow="40"')
    expect(output).to include('aria-valuemin="0"')
    expect(output).to include('aria-valuemax="100"')
    expect(output).to include("bg-secondary")
  end

  it "includes a default aria-label of 'Progress' for accessible name" do
    output = described_class.new(value: 50).call
    expect(output).to include('aria-label="Progress"')
  end

  it "accepts a custom label for contextual accessible name" do
    output = described_class.new(value: 70, aria_label: "File upload progress").call
    expect(output).to include('aria-label="File upload progress"')
  end

  it "translates the indicator by the remaining percentage" do
    output = described_class.new(value: 40).call
    expect(output).to include("translateX(-60")
    expect(output).to include("bg-primary")
  end

  it "clamps out-of-range values" do
    output = described_class.new(value: 150).call
    expect(output).to include("translateX(-0")
  end

  it "supports a custom max" do
    output = described_class.new(value: 1, max: 4).call
    expect(output).to include('aria-valuemax="4"')
    expect(output).to include("translateX(-75")
  end
end
