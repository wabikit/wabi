# frozen_string_literal: true

require "wabi"
require_relative "tooltip"
require_relative "tooltip_trigger"
require_relative "tooltip_content"

RSpec.describe "Tooltip composition" do
  it "wires the root with controller + open/close delay values" do
    output = Components::UI::Tooltip.new(open_delay: 500, close_delay: 200).call { "" }
    expect(output).to include('data-controller="wabi--tooltip"')
    expect(output).to include('data-wabi--tooltip-open-delay-value="500"')
    expect(output).to include('data-wabi--tooltip-close-delay-value="200"')
  end

  it "TooltipTrigger emits <button> with the trigger target" do
    output = Components::UI::TooltipTrigger.new.call { "Info" }
    expect(output).to include('<button')
    expect(output).to include('data-wabi--tooltip-target="trigger"')
    expect(output).to include("Info")
  end

  it "TooltipContent starts with data-state=closed + inert on content (positioner stays interactive)" do
    output = Components::UI::TooltipContent.new.call { "Hi" }
    expect(output).to include('data-wabi--tooltip-target="positioner"')
    expect(output).to include('data-wabi--tooltip-target="content" data-state="closed"')
    expect(output).to match(/data-wabi--tooltip-target="content"[^>]*\binert\b/)
    expect(output).not_to match(/data-wabi--tooltip-target="positioner"[^>]*hidden/)
  end

  it "TooltipContent includes motion-reduce:transition-none for prefers-reduced-motion support" do
    output = Components::UI::TooltipContent.new.call { "Hi" }
    expect(output).to include("motion-reduce:transition-none")
  end

  it "carries portal-value true by default" do
    output = Components::UI::Tooltip.new.call
    expect(output).to include('data-wabi--tooltip-portal-value="true"')
  end

  it "allows portal: false to keep v0.4 in-tree behavior" do
    output = Components::UI::Tooltip.new(portal: false).call
    expect(output).to include('data-wabi--tooltip-portal-value="false"')
  end

  # WCAG-AA fix: names-labels — attrs passthrough so icon-only triggers can receive aria-label
  it "TooltipTrigger forwards caller attrs (e.g. aria-label) to the button element" do
    output = Components::UI::TooltipTrigger.new("aria-label": "More information").call { "" }
    expect(output).to include('aria-label="More information"')
    expect(output).to include('data-wabi--tooltip-target="trigger"')
  end

  it "TooltipTrigger does not forward :class as a separate attr (extracts it cleanly)" do
    output = Components::UI::TooltipTrigger.new(class: "custom-class", "aria-label": "Help").call { "" }
    expect(output).to include('class="custom-class"')
    expect(output).to include('aria-label="Help"')
    # :class must not appear twice or cause malformed markup
    expect(output.scan('class=').size).to eq(1)
  end

  it "composes into a full tooltip" do
    composed = Class.new(Phlex::HTML) do
      def view_template
        render Components::UI::Tooltip.new do
          render Components::UI::TooltipTrigger.new { "?" }
          render Components::UI::TooltipContent.new { "Helpful hint" }
        end
      end
    end.new.call

    expect(composed).to include('data-controller="wabi--tooltip"')
    expect(composed).to include('data-wabi--tooltip-target="trigger"')
    expect(composed).to include('data-wabi--tooltip-target="content"')
    expect(composed).to include("Helpful hint")
  end
end
