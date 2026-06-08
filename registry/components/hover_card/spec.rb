# frozen_string_literal: true

require "wabi"
require_relative "hover_card"
require_relative "hover_card_trigger"
require_relative "hover_card_content"

RSpec.describe "HoverCard composition" do
  describe Components::UI::HoverCard do
    it "renders a <div> wired to the wabi--hover-card controller" do
      output = described_class.new.call
      expect(output).to include('data-controller="wabi--hover-card"')
    end

    it "serializes open/close delays and portal flag" do
      output = described_class.new(open_delay: 200, close_delay: 100, portal: false).call
      expect(output).to include('data-wabi--hover-card-open-delay-value="200"')
      expect(output).to include('data-wabi--hover-card-close-delay-value="100"')
      expect(output).to include('data-wabi--hover-card-portal-value="false"')
    end

    it "yields its block content and applies the id" do
      output = described_class.new(id: "hc1").call { "INNER" }
      expect(output).to include("INNER")
      expect(output).to include('id="hc1"')
    end
  end

  describe Components::UI::HoverCardTrigger do
    it "renders a <button> (not <a>) targeting the trigger" do
      output = described_class.new.call { "@wabi" }
      expect(output).to include("<button")
      expect(output).not_to include("<a ")
      expect(output).to include('data-wabi--hover-card-target="trigger"')
      expect(output).to include("@wabi")
    end

    it "renders without a block" do
      output = described_class.new.call
      expect(output).to include('data-wabi--hover-card-target="trigger"')
    end

    it "has an implicit button role — no explicit tabindex needed" do
      output = described_class.new.call { "x" }
      expect(output).to include("<button")
    end

    it "forwards caller attrs including aria-label to the button" do
      output = described_class.new("aria-label": "View @wabi profile").call { "@wabi" }
      expect(output).to include('aria-label="View @wabi profile"')
    end

    it "sets aria-haspopup=true on the trigger button (Zag never provides this)" do
      output = described_class.new.call { "@wabi" }
      expect(output).to include('aria-haspopup="true"')
    end
  end

  describe Components::UI::HoverCardContent do
    it "renders a positioner + content with inert default" do
      output = described_class.new.call { "Card body" }
      expect(output).to include('data-wabi--hover-card-target="positioner"')
      expect(output).to include('data-wabi--hover-card-target="content"')
      expect(output).to include("Card body")
    end

    it "renders without a block" do
      output = described_class.new.call
      expect(output).to include('data-wabi--hover-card-target="content"')
    end
  end
end
