# frozen_string_literal: true

require "wabi"
require_relative "skeleton"

RSpec.describe Components::UI::Skeleton do
  it "renders an animate-pulse muted rounded div" do
    output = described_class.new.call
    expect(output).to include("<div")
    expect(output).to include("animate-pulse")
    expect(output).to include("rounded-md")
    expect(output).to include("bg-muted")
  end

  it "merges a sizing class instead of replacing the base" do
    output = described_class.new(class: "h-4 w-32").call
    expect(output).to include("h-4")
    expect(output).to include("w-32")
    expect(output).to include("animate-pulse")
  end

  # a11y regression: WCAG-AA live-regions fix
  it "includes role=status so aria-label is valid and loading is announced to AT" do
    output = described_class.new.call
    expect(output).to include('role="status"')
  end

  it "includes aria-busy=true to signal loading state to assistive technologies" do
    output = described_class.new.call
    expect(output).to include('aria-busy="true"')
  end

  it "includes a default aria-label describing the loading state" do
    output = described_class.new.call
    expect(output).to match(/aria-label="Loading/)
  end

  it "allows callers to override aria-label via attrs" do
    output = described_class.new("aria-label": "Loading avatar").call
    expect(output).to include('aria-label="Loading avatar"')
    expect(output).not_to match(/aria-label="Loading…"/)
  end

  it "allows callers to override aria-busy via attrs" do
    output = described_class.new("aria-busy": "false").call
    expect(output).to include('aria-busy="false"')
    expect(output).not_to include('aria-busy="true"')
  end
end
