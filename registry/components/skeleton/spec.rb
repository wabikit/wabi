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
end
