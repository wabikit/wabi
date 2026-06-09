# frozen_string_literal: true

require "wabi"
require_relative "radio_group"
require_relative "radio_group_item"
require_relative "radio_group_indicator"

RSpec.describe "RadioGroup composition" do
  describe Components::UI::RadioGroup do
    it "renders a role=radiogroup div wired to the wabi--radio-group controller" do
      output = described_class.new(name: "plan").call
      expect(output).to include('<div')
      expect(output).to include('role="radiogroup"')
      expect(output).to include('data-controller="wabi--radio-group"')
      expect(output).to include('data-wabi--radio-group-name-value="plan"')
    end

    it "carries the value as a Stimulus value" do
      output = described_class.new(name: "plan", value: "pro").call
      expect(output).to include('data-wabi--radio-group-value-value="pro"')
    end

    it "carries disabled-value" do
      output = described_class.new(name: "plan", disabled: true).call
      expect(output).to include('data-wabi--radio-group-disabled-value="true"')
    end

    it "renders aria-label when aria_label: is supplied (accessible name for the radiogroup)" do
      output = described_class.new(name: "plan", aria_label: "Subscription plan").call
      expect(output).to include('aria-label="Subscription plan"')
    end

    it "omits aria-label attribute when aria_label: is nil (default)" do
      output = described_class.new(name: "plan").call
      expect(output).not_to include("aria-label")
    end

    it "renders without a name: and omits the name attribute" do
      out = described_class.new.call
      expect(out).not_to include('name="')
    end
  end

  describe Components::UI::RadioGroupItem do
    it "renders a <label> wrapper carrying the item value" do
      output = described_class.new(value: "free").call { "Free" }
      expect(output).to start_with("<label")
      expect(output).to include('data-wabi--radio-group-target="item"')
      expect(output).to include('data-wabi-value="free"')
      expect(output).to include("Free")
    end

    it "includes a hidden input target for form submission wiring" do
      output = described_class.new(value: "free").call { "Free" }
      expect(output).to include('data-wabi--radio-group-target="hiddenInput"')
    end

    it "includes an item control target (the radio dot)" do
      output = described_class.new(value: "free").call { "Free" }
      expect(output).to include('data-wabi--radio-group-target="itemControl"')
    end
  end

  describe Components::UI::RadioGroupIndicator do
    it "renders a span wired as the indicator target with default closed state" do
      output = described_class.new.call
      expect(output).to include('data-wabi--radio-group-target="itemIndicator"')
      expect(output).to include('data-state="unchecked"')
    end
  end
end
