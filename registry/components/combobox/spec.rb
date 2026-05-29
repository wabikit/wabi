# frozen_string_literal: true

require "wabi"
require "json"
require_relative "combobox"
require_relative "combobox_label"
require_relative "combobox_control"
require_relative "combobox_input"
require_relative "combobox_trigger"
require_relative "combobox_positioner"
require_relative "combobox_content"
require_relative "combobox_item"
require_relative "combobox_item_indicator"

RSpec.describe "Combobox composition" do
  describe Components::UI::Combobox do
    it "renders a div wired to the wabi--combobox controller" do
      output = described_class.new(name: "framework", items: []).call
      expect(output).to include('<div')
      expect(output).to include('data-controller="wabi--combobox"')
      expect(output).to include('data-wabi--combobox-name-value="framework"')
    end

    it "serializes items to JSON" do
      items = [{ value: "rails", label: "Ruby on Rails" }]
      output = described_class.new(name: "framework", items: items).call
      expect(output).to include('data-wabi--combobox-items-value=')
      expect(output).to include('rails')
      expect(output).to include('Ruby on Rails')
    end

    it "carries placeholder + initial value" do
      output = described_class.new(name: "framework", items: [], value: "rails", placeholder: "Pick...").call
      expect(output).to include('data-wabi--combobox-value-value="rails"')
      expect(output).to include('data-wabi--combobox-placeholder-value="Pick..."')
    end

    it "defaults portal-value to true; allows portal: false to opt out" do
      out_on  = described_class.new(name: "x", items: []).call
      out_off = described_class.new(name: "x", items: [], portal: false).call
      expect(out_on).to include('data-wabi--combobox-portal-value="true"')
      expect(out_off).to include('data-wabi--combobox-portal-value="false"')
    end
  end

  describe Components::UI::ComboboxInput do
    it "renders an <input> wired to the input target" do
      output = described_class.new.call
      expect(output).to include('<input')
      expect(output).to include('data-wabi--combobox-target="input"')
    end
  end

  describe Components::UI::ComboboxTrigger do
    it "renders a <button> wired to the trigger target" do
      output = described_class.new.call
      expect(output).to include('<button')
      expect(output).to include('data-wabi--combobox-target="trigger"')
    end
  end

  describe Components::UI::ComboboxPositioner do
    it "renders the positioner target" do
      output = described_class.new.call
      expect(output).to include('data-wabi--combobox-target="positioner"')
    end
  end

  describe Components::UI::ComboboxContent do
    it "renders the content target as a <ul> with initial inert" do
      output = described_class.new.call
      expect(output).to include('<ul')
      expect(output).to include('data-wabi--combobox-target="content"')
      expect(output).to include('inert')
      expect(output).to include('data-state="closed"')
    end
  end

  describe Components::UI::ComboboxItem do
    it "renders an <li> wired as the item target with the value" do
      output = described_class.new(value: "rails").call { "Ruby on Rails" }
      expect(output).to include('<li')
      expect(output).to include('data-wabi--combobox-target="item"')
      expect(output).to include('data-wabi-value="rails"')
      expect(output).to include("Ruby on Rails")
    end

    it "does NOT emit data-disabled when @disabled is false" do
      output = described_class.new(value: "rails").call { "x" }
      expect(output).not_to include('data-disabled')
    end

    it "emits data-disabled when @disabled is true" do
      output = described_class.new(value: "rails", disabled: true).call { "x" }
      expect(output).to include('data-disabled')
    end
  end

  describe Components::UI::ComboboxItemIndicator do
    it "renders a hidden span wired as the itemIndicator target" do
      output = described_class.new.call
      expect(output).to include('data-wabi--combobox-target="itemIndicator"')
      # Match the boolean `hidden` ATTRIBUTE on the span, not a stray
      # substring inside a class name or other attribute value.
      expect(output).to match(/<span[^>]*\shidden(\s|>|\/)/)
    end
  end
end
