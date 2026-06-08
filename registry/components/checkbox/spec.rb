# frozen_string_literal: true

require "wabi"
require_relative "checkbox"

RSpec.describe Components::UI::Checkbox do
  it "renders a <label> wrapper wired to the Stimulus controller" do
    output = described_class.new.call
    expect(output).to include('data-controller="wabi--checkbox"')
    expect(output).to start_with("<label")
  end

  it "renders a real <input type=checkbox> (visually hidden) for keyboard + form submission" do
    output = described_class.new(name: "agree", value: "yes").call
    expect(output).to include('type="checkbox"')
    expect(output).to include('name="agree"')
    expect(output).to include('value="yes"')
    expect(output).to include('class="sr-only"')
  end

  it "renders the visual control span with data-state=unchecked by default" do
    output = described_class.new.call
    expect(output).to include('data-state="unchecked"')
    expect(output).to include('aria-hidden="true"')
    expect(output).to include('data-wabi--checkbox-target="control"')
  end

  it "hides the indicator when unchecked" do
    output = described_class.new.call
    expect(output).to match(/<span[^>]*data-wabi--checkbox-target="indicator"[^>]*hidden/)
  end

  it "marks the input checked and state=checked when checked: true" do
    output = described_class.new(checked: true).call
    expect(output).to include('data-state="checked"')
    expect(output).to match(/<input[^>]*type="checkbox"[^>]*checked/)
  end

  it "carries id through to the hidden input so an external <label for=...> associates" do
    output = described_class.new(id: "terms").call
    expect(output).to match(/<input[^>]*type="checkbox"[^>]*id="terms"/)
  end

  it "renders visible label text from a block (accessible name)" do
    output = described_class.new.call { "I agree" }
    expect(output).to include("I agree")
  end

  it "renders visible label text from the label: kwarg" do
    output = described_class.new(label: "Subscribe").call
    expect(output).to include("Subscribe")
  end

  # WCAG 2.4.11 focus-appearance regression (focus ring fix)
  it "label wrapper carries focus-within ring classes so keyboard focus is visible" do
    output = described_class.new.call
    expect(output).to include("focus-within:ring-2")
    expect(output).to include("focus-within:ring-ring")
    expect(output).to include("focus-within:ring-offset-2")
  end

  it "control span does NOT carry focus-visible:ring classes (it is aria-hidden and unfocusable)" do
    output = described_class.new.call
    # Extract just the control span's class to confirm focus-visible:ring is absent there
    expect(output).not_to include("focus-visible:ring-2")
    expect(output).not_to include("focus-visible:ring-ring")
  end
end
