# frozen_string_literal: true

require "wabi"
require_relative "../button/button"
require_relative "popover"
require_relative "popover_trigger"
require_relative "popover_content"
require_relative "popover_close"

RSpec.describe "Popover composition" do
  it "wires the root with controller + open/modal values" do
    output = Components::UI::Popover.new(modal: true).call { "" }
    expect(output).to include('data-controller="wabi--popover"')
    expect(output).to include('data-wabi--popover-open-value="false"')
    expect(output).to include('data-wabi--popover-modal-value="true"')
  end

  it "PopoverTrigger emits <button> with the trigger target" do
    output = Components::UI::PopoverTrigger.new.call { "Open" }
    expect(output).to include('<button')
    expect(output).to include('data-wabi--popover-target="trigger"')
  end

  it "PopoverContent starts with data-state=closed + inert on content" do
    output = Components::UI::PopoverContent.new.call { "" }
    expect(output).to include('data-wabi--popover-target="positioner"')
    expect(output).to include('data-wabi--popover-target="content" data-state="closed"')
    expect(output).to match(/data-wabi--popover-target="content"[^>]*\binert\b/)
    expect(output).not_to match(/data-wabi--popover-target="positioner"[^>]*hidden/)
  end

  it "PopoverContent includes motion-reduce:transition-none for prefers-reduced-motion support" do
    output = Components::UI::PopoverContent.new.call { "" }
    expect(output).to include("motion-reduce:transition-none")
  end

  it "PopoverClose renders an outlined Button tagged as closeTrigger" do
    output = Components::UI::PopoverClose.new.call { "Done" }
    expect(output).to include('<button')
    expect(output).to include('data-wabi--popover-target="closeTrigger"')
  end

  it "carries portal-value true by default" do
    output = Components::UI::Popover.new.call { "" }
    expect(output).to include('data-wabi--popover-portal-value="true"')
  end

  it "allows portal: false to keep v0.4 in-tree behavior" do
    output = Components::UI::Popover.new(portal: false).call { "" }
    expect(output).to include('data-wabi--popover-portal-value="false"')
  end

  # Regression: @attrs passthrough — aria-label and other caller attrs must
  # reach the <button> so icon-only triggers have an accessible name.
  it "PopoverTrigger passes caller aria-label through to the button element" do
    output = Components::UI::PopoverTrigger.new("aria-label": "Open settings").call { "" }
    expect(output).to include('aria-label="Open settings"')
    # Zag target wiring must still be present
    expect(output).to include('data-wabi--popover-target="trigger"')
  end

  it "PopoverTrigger passes arbitrary attrs (e.g. id, tabindex) through to the button" do
    output = Components::UI::PopoverTrigger.new(id: "my-trigger", tabindex: "0").call { "" }
    expect(output).to include('id="my-trigger"')
    expect(output).to include('tabindex="0"')
    expect(output).to include('data-wabi--popover-target="trigger"')
  end

  it "composes into a full popover" do
    composed = Class.new(Phlex::HTML) do
      def view_template
        render Components::UI::Popover.new do
          render Components::UI::PopoverTrigger.new { "Open" }
          render Components::UI::PopoverContent.new do
            p { "Popover body content." }
            render Components::UI::PopoverClose.new { "Close" }
          end
        end
      end
    end.new.call

    expect(composed).to include('data-controller="wabi--popover"')
    expect(composed).to include('data-wabi--popover-target="trigger"')
    expect(composed).to include('data-wabi--popover-target="content"')
    expect(composed).to include("Popover body content.")
  end
end
