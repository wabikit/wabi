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

  # WCAG 2.4.11 focus-appearance: the ring shows on KEYBOARD focus only (has-[:focus-visible]),
  # not on mouse click — focus-within would draw it around the label on every click.
  it "label wrapper shows the focus ring only on keyboard focus (has-[:focus-visible])" do
    output = described_class.new.call
    expect(output).to include("has-[:focus-visible]:ring-2")
    expect(output).to include("has-[:focus-visible]:ring-ring")
    expect(output).to include("has-[:focus-visible]:ring-offset-2")
    expect(output).not_to include("focus-within:ring")
  end

  # The clickable label must stay sized to its content; without w-fit it stretches
  # full-width inside a flex/grid parent and the empty space beside the text toggles.
  it "label wrapper is content-width (w-fit) so only the box + text are clickable" do
    expect(described_class.new(label: "x").call).to include("w-fit")
  end

  it "control span does NOT carry focus-visible:ring classes (it is aria-hidden and unfocusable)" do
    output = described_class.new.call
    # Extract just the control span's class to confirm focus-visible:ring is absent there
    expect(output).not_to include("focus-visible:ring-2")
    expect(output).not_to include("focus-visible:ring-ring")
  end
end
