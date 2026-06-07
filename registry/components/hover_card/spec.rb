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
    it "renders an anchor targeting the trigger" do
      output = described_class.new.call { "@wabi" }
      expect(output).to include('data-wabi--hover-card-target="trigger"')
      expect(output).to include("@wabi")
    end

    it "renders without a block" do
      output = described_class.new.call
      expect(output).to include('data-wabi--hover-card-target="trigger"')
    end

    it "is keyboard-focusable before hydration" do
      output = described_class.new.call { "x" }
      expect(output).to include('tabindex="0"')
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
