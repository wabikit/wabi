# frozen_string_literal: true

require "wabi"
require_relative "switch"

RSpec.describe Components::UI::Switch do
  it "renders role=switch button" do
    output = described_class.new.call
    expect(output).to include('role="switch"')
  end

  it "starts with aria-checked=false and data-state=unchecked" do
    output = described_class.new.call
    expect(output).to include('aria-checked="false"')
    expect(output).to include('data-state="unchecked"')
  end

  it "renders Stimulus controller wiring" do
    output = described_class.new.call
    expect(output).to include('data-controller="wabi--switch"')
    expect(output).to include('data-wabi--switch-target="root"')
  end

  it "renders thumb span" do
    output = described_class.new.call
    expect(output).to include('data-wabi--switch-target="thumb"')
  end

  it "sets aria-checked=true and data-state=checked when checked: true" do
    output = described_class.new(checked: true).call
    expect(output).to include('aria-checked="true"')
    expect(output).to include('data-state="checked"')
  end

  it "renders hidden input with name for form submission" do
    output = described_class.new(name: "notifications", checked: true).call
    expect(output).to include('<input type="hidden"')
    expect(output).to include('name="notifications"')
    expect(output).to include('value="1"')
  end
end
