# frozen_string_literal: true

require "wabi"
require_relative "switch"

RSpec.describe Components::UI::Switch do
  it "renders a <label> wrapper wired to the Stimulus controller" do
    output = described_class.new.call
    expect(output).to include('data-controller="wabi--switch"')
    expect(output).to start_with("<label")
  end

  it "renders a real <input type=checkbox> (visually hidden) for keyboard + form submission" do
    output = described_class.new(name: "notifications").call
    expect(output).to include('type="checkbox"')
    expect(output).to include('name="notifications"')
    expect(output).to include('class="sr-only"')
  end

  it "renders the visual control with data-state=unchecked by default" do
    output = described_class.new.call
    expect(output).to include('data-state="unchecked"')
    expect(output).to include('aria-hidden="true"')
    expect(output).to include('data-wabi--switch-target="control"')
  end

  it "renders the thumb span with matching data-state" do
    output = described_class.new.call
    expect(output).to include('data-wabi--switch-target="thumb"')
  end

  it "flips state=checked + sets input checked when checked: true" do
    output = described_class.new(checked: true).call
    expect(output).to include('data-state="checked"')
    expect(output).to match(/<input[^>]*type="checkbox"[^>]*checked/)
  end

  it "carries id through to the hidden input for label association" do
    output = described_class.new(id: "notifications").call
    expect(output).to match(/<input[^>]*type="checkbox"[^>]*id="notifications"/)
  end

  it "forwards aria_label: to the hidden input as its accessible name" do
    output = described_class.new(name: "notif", aria_label: "Notifications").call
    expect(output).to match(/<input[^>]*type="checkbox"[^>]*aria-label="Notifications"/)
  end

  it "renders a visible label part wired to the controller when given a block" do
    output = described_class.new(name: "notif").call { "Email me" }
    expect(output).to include('data-wabi--switch-target="label"')
    expect(output).to include("Email me")
  end

  it "does not server-render a dangling aria-labelledby on the hidden input (no label part)" do
    # Zag's getHiddenInputProps points aria-labelledby at the label part id; with
    # no label rendered the controller strips it client-side. The server output
    # must never emit it so there is no empty/dangling reference, and no label
    # part is rendered when no block is given.
    output = described_class.new(name: "notif").call
    expect(output).not_to include("aria-labelledby")
    expect(output).not_to include('data-wabi--switch-target="label"')
  end

  it "label wrapper is content-width (w-fit) so empty space beside it doesn't toggle" do
    expect(described_class.new(name: "x").call).to include("w-fit")
  end
end
