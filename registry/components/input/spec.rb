# frozen_string_literal: true

require "wabi"
require_relative "input"

RSpec.describe Components::UI::Input do
  it "renders an input element with default text type" do
    output = described_class.new.call
    expect(output).to include('<input type="text"')
    expect(output).to include("h-10")
  end

  it "accepts a custom type" do
    output = described_class.new(type: "email").call
    expect(output).to include('type="email"')
  end

  it "forwards name, value, placeholder" do
    output = described_class.new(name: "email", value: "foo@bar.com", placeholder: "you@example.com").call
    expect(output).to include('name="email"')
    expect(output).to include('value="foo@bar.com"')
    expect(output).to include('placeholder="you@example.com"')
  end

  it "merges user class with base tokens" do
    output = described_class.new(class: "h-12 mt-2").call
    expect(output).to include("h-12")     # user wins for h-* group
    expect(output).to include("mt-2")     # non-conflict preserved
  end

  it "forwards aria_label so callers can give the control an accessible name" do
    expect(described_class.new(aria_label: "Email").call).to include('aria-label="Email"')
  end
end
