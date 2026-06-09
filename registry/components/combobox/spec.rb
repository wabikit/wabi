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
require_relative "combobox_loading"
require_relative "combobox_error"

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

    it "emits async values when url: is given" do
      output = described_class.new(name: "f", items: [], url: "/search", param: "term", debounce: 300, min_length: 2).call
      expect(output).to include('data-wabi--combobox-url-value="/search"')
      expect(output).to include('data-wabi--combobox-param-value="term"')
      expect(output).to include('data-wabi--combobox-debounce-value="300"')
      expect(output).to include('data-wabi--combobox-min-length-value="2"')
    end

    it "omits the url value when not async (sync mode unchanged)" do
      output = described_class.new(name: "f", items: []).call
      expect(output).not_to include('wabi--combobox-url-value')
    end

    it "renders without a name: and omits the name attribute on the hidden input" do
      out = described_class.new(items: []).call
      expect(out).not_to include('name="')
    end
  end

  describe Components::UI::ComboboxLoading do
    it "renders a loading slot wired as the loading target" do
      output = described_class.new.call { "Loading…" }
      expect(output).to include('data-wabi--combobox-target="loading"')
      expect(output).to include("Loading…")
    end

    # WCAG live-region fix: element must NOT carry the HTML hidden attribute so
    # it stays in the accessibility tree at page load. A11y announcement fires
    # when content changes; the `hidden` attr removes the node from the a11y tree.
    it "does NOT use the hidden attribute (always in a11y tree for live-region)" do
      output = described_class.new.call { "Loading…" }
      expect(output).not_to match(/<div[^>]*\shidden(\s|>|\/)/)
    end

    it "includes aria-live polite for screen-reader announcements" do
      output = described_class.new.call { "Loading…" }
      expect(output).to include('aria-live="polite"')
    end

    it "includes aria-atomic true so the full message is read on update" do
      output = described_class.new.call { "Loading…" }
      expect(output).to include('aria-atomic="true"')
    end

    it "starts visually hidden via sr-only class so it is invisible until active" do
      output = described_class.new.call { "Loading…" }
      expect(output).to include("sr-only")
    end
  end

  describe Components::UI::ComboboxError do
    it "renders an error slot wired as the error target" do
      output = described_class.new.call { "Couldn't load results" }
      expect(output).to include('data-wabi--combobox-target="error"')
      expect(output).to include("Couldn&#39;t load results")
    end

    it "includes aria-live polite for screen-reader announcements" do
      output = described_class.new.call { "Couldn't load results" }
      expect(output).to include('aria-live="polite"')
    end

    # WCAG live-region fix: element must NOT carry the HTML hidden attribute so
    # it stays in the accessibility tree at page load. A11y announcement fires
    # when content changes; the `hidden` attr removes the node from the a11y tree.
    it "does NOT use the hidden attribute (always in a11y tree for live-region)" do
      output = described_class.new.call { "Couldn't load results" }
      expect(output).not_to match(/<div[^>]*\shidden(\s|>|\/)/)
    end

    it "includes aria-atomic true so the full message is read on update" do
      output = described_class.new.call { "Couldn't load results" }
      expect(output).to include('aria-atomic="true"')
    end

    it "starts visually hidden via sr-only class so it is invisible until active" do
      output = described_class.new.call { "Couldn't load results" }
      expect(output).to include("sr-only")
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

    it "includes motion-reduce:transition-none for prefers-reduced-motion support" do
      output = described_class.new.call
      expect(output).to include("motion-reduce:transition-none")
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
