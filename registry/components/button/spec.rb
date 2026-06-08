# frozen_string_literal: true

# This spec is shipped to the user's project as documentation; it runs
# inside the registry monorepo via a meta-runner in CI (added in Task 28).

require "wabi"
require_relative "button"

RSpec.describe Components::UI::Button do
  it "renders a button element with default variant classes" do
    output = described_class.new.call { "Click me" }
    expect(output).to include('<button')
    expect(output).to include("bg-primary")
    expect(output).to include("h-10")
    expect(output).to include("Click me")
  end

  it "applies appearance variant" do
    output = described_class.new(appearance: :destructive).call { "Delete" }
    expect(output).to include("bg-destructive")
  end

  it "applies size variant" do
    output = described_class.new(size: :lg).call { "Save" }
    expect(output).to include("h-11")
  end

  it "passes through user class merging with variant tokens" do
    output = described_class.new(class: "h-20 shadow").call { "x" }
    expect(output).to include("h-20")    # user h-20 wins over default h-10
    expect(output).to include("shadow")  # non-conflicting preserved
  end

  it "forwards aria-* and data-* attributes" do
    output = described_class.new(aria_label: "save", data_test: "btn").call
    expect(output).to include('aria-label="save"')
    expect(output).to include('data-test="btn"')
  end

  # WCAG AA regression: size :icon buttons must carry an accessible name via
  # aria-label so screen readers can announce the button's purpose.
  it "passes aria-label through to the button element when size is :icon" do
    output = described_class.new(size: :icon, aria_label: "Close dialog").call { "×" }
    expect(output).to include('aria-label="Close dialog"')
    expect(output).to include("h-10 w-10")
  end
end
