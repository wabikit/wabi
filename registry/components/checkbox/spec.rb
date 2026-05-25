# frozen_string_literal: true

require "wabi"
require_relative "checkbox"

RSpec.describe Components::UI::Checkbox do
  it "renders a wrapper div with the Stimulus controller" do
    output = described_class.new.call
    expect(output).to include('data-controller="wabi--checkbox"')
  end

  it "renders a role=checkbox button" do
    output = described_class.new.call
    expect(output).to include('role="checkbox"')
  end

  it "sets aria-checked=false by default" do
    output = described_class.new.call
    expect(output).to include('aria-checked="false"')
    expect(output).to include('data-state="unchecked"')
  end

  it "sets aria-checked=true when checked: true" do
    output = described_class.new(checked: true).call
    expect(output).to include('aria-checked="true"')
    expect(output).to include('data-state="checked"')
  end

  it "renders a hidden input for form submission" do
    output = described_class.new(name: "agree", checked: true).call
    expect(output).to include('<input type="hidden"')
    expect(output).to include('name="agree"')
  end
end
