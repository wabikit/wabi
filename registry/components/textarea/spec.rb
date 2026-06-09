# frozen_string_literal: true

require "wabi"
require_relative "textarea"

RSpec.describe Components::UI::Textarea do
  it "renders a textarea element" do
    output = described_class.new.call
    expect(output).to include("<textarea")
    expect(output).to include("min-h-")
  end

  it "renders content from block" do
    output = described_class.new.call { "default text" }
    expect(output).to include(">default text</textarea>")
  end

  it "forwards rows, cols, name" do
    output = described_class.new(rows: 4, cols: 40, name: "bio").call
    expect(output).to include('rows="4"')
    expect(output).to include('cols="40"')
    expect(output).to include('name="bio"')
  end

  # Regression: label association attrs must pass through so callers can
  # satisfy WCAG 1.3.1 / 4.1.2 without a visible label (finding: names-labels).
  it "passes aria-label through to the textarea element" do
    output = described_class.new(aria_label: "Biography").call
    expect(output).to include('aria-label="Biography"')
  end

  it "passes aria-labelledby through to the textarea element" do
    output = described_class.new(aria_labelledby: "bio-label").call
    expect(output).to include('aria-labelledby="bio-label"')
  end

  it "sets aria-invalid when invalid: true" do
    expect(described_class.new(invalid: true).call).to include('aria-invalid="true"')
  end

  it "carries the invalid red-border styling keyed off aria-invalid" do
    expect(described_class.new.call).to include("aria-[invalid=true]:border-destructive")
  end

  it "omits aria-invalid by default" do
    expect(described_class.new.call).not_to include("aria-invalid")
  end
end
