# frozen_string_literal: true

require "wabi"
require "json"
require_relative "toggle_group"
require_relative "toggle_group_item"

RSpec.describe "ToggleGroup composition" do
  describe Components::UI::ToggleGroup do
    it "renders a role=group div wired to the wabi--toggle-group controller" do
      output = described_class.new(type: :single).call
      expect(output).to include('<div')
      expect(output).to include('role="group"')
      expect(output).to include('data-controller="wabi--toggle-group"')
    end

    it "carries the multiple flag" do
      output = described_class.new(type: :multiple).call
      expect(output).to include('data-wabi--toggle-group-multiple-value="true"')
    end

    it "single mode default-value is a single-element JSON array" do
      output = described_class.new(type: :single, value: "center").call
      expect(output).to include('data-wabi--toggle-group-value-value="[&quot;center&quot;]"')
    end

    it "multiple mode default-value is a JSON array" do
      output = described_class.new(type: :multiple, value: ["bold", "italic"]).call
      expect(output).to include('data-wabi--toggle-group-value-value="[&quot;bold&quot;,&quot;italic&quot;]"')
    end

    it "single mode with no value emits an empty array" do
      output = described_class.new(type: :single).call
      expect(output).to include('data-wabi--toggle-group-value-value="[]"')
    end

    it "carries name as a Stimulus value" do
      output = described_class.new(type: :single, name: "align").call
      expect(output).to include('data-wabi--toggle-group-name-value="align"')
    end
  end

  describe Components::UI::ToggleGroupItem do
    it "renders a <button> with the item value as data-wabi-value" do
      output = described_class.new(value: "left").call { "Left" }
      expect(output).to start_with("<button")
      expect(output).to include('data-wabi--toggle-group-target="item"')
      expect(output).to include('data-wabi-value="left"')
      expect(output).to include('data-state="off"')
      expect(output).to include("Left")
    end

    it "carries disabled state" do
      output = described_class.new(value: "left", disabled: true).call { "Left" }
      expect(output).to include('data-wabi-disabled="true"')
    end
  end
end
