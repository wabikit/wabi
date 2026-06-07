# frozen_string_literal: true

require "wabi"
require_relative "collapsible"
require_relative "collapsible_trigger"
require_relative "collapsible_content"

RSpec.describe "Collapsible composition" do
  describe Components::UI::Collapsible do
    it "renders a <div> wired to the wabi--collapsible controller" do
      output = described_class.new.call
      expect(output).to include('data-controller="wabi--collapsible"')
    end

    it "serializes open and disabled" do
      output = described_class.new(open: true, disabled: true).call
      expect(output).to include('data-wabi--collapsible-open-value="true"')
      expect(output).to include('data-wabi--collapsible-disabled-value="true"')
    end

    it "yields its block" do
      output = described_class.new.call { "INNER" }
      expect(output).to include("INNER")
    end
  end

  describe Components::UI::CollapsibleTrigger do
    it "renders a button targeting the trigger" do
      output = described_class.new.call { "Toggle" }
      expect(output).to include('data-wabi--collapsible-target="trigger"')
      expect(output).to include("Toggle")
    end

    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--collapsible-target="trigger"')
    end

    it "renders a real submit-safe button" do
      expect(described_class.new.call { "x" }).to include('type="button"')
    end
  end

  describe Components::UI::CollapsibleContent do
    it "renders a content region with the grid animation wrapper" do
      output = described_class.new.call { "Body" }
      expect(output).to include('data-wabi--collapsible-target="content"')
      expect(output).to include("Body")
      expect(output).to include("grid-rows-[0fr]")
    end

    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--collapsible-target="content"')
    end

    it "starts closed" do
      expect(described_class.new.call { "x" }).to include('data-state="closed"')
    end
  end
end
