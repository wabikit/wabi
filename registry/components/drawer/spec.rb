# frozen_string_literal: true

require "wabi"
require_relative "../button/button"
require_relative "drawer"
require_relative "drawer_trigger"
require_relative "drawer_content"
require_relative "drawer_header"
require_relative "drawer_title"
require_relative "drawer_description"
require_relative "drawer_footer"
require_relative "drawer_close"

RSpec.describe "Drawer composition" do
  it "reuses the wabi--dialog controller and exposes the side as data-wabi-side" do
    output = Components::UI::Drawer.new(side: :left).call { "" }
    expect(output).to include('data-controller="wabi--dialog"')
    expect(output).to include('data-wabi-side="left"')
    expect(output).to include('data-wabi--dialog-modal-value="true"')
  end

  it "DrawerTrigger emits <button> with the trigger target" do
    output = Components::UI::DrawerTrigger.new.call { "Open" }
    expect(output).to include('<button')
    expect(output).to include('data-wabi--dialog-target="trigger"')
  end

  it "DrawerContent positions per side (default right)" do
    expected = {
      top:    "inset-x-0 top-0",
      right:  "inset-y-0 right-0",
      bottom: "inset-x-0 bottom-0",
      left:   "inset-y-0 left-0",
    }
    expected.each do |side, classes|
      output = Components::UI::DrawerContent.new(side: side).call { "" }
      classes.split.each { |c| expect(output).to include(c) }
    end
  end

  it "DrawerContent starts with backdrop AND content hidden, portal NOT hidden" do
    # v0.1.x: visibility moved to `data-state` for animation support.
    output = Components::UI::DrawerContent.new.call { "" }
    expect(output).to include('data-wabi--dialog-target="backdrop" data-state="closed"')
    expect(output).to include('data-state="closed" data-wabi--dialog-target="content"')
    expect(output).not_to match(/data-wabi--dialog-target="portal"[^>]*hidden/)
  end

  it "DrawerContent has role=dialog and aria-modal=true" do
    output = Components::UI::DrawerContent.new.call { "" }
    expect(output).to include('role="dialog"')
    expect(output).to include('aria-modal="true"')
  end

  it "DrawerClose renders an outlined Button tagged as closeTrigger" do
    output = Components::UI::DrawerClose.new.call { "Cancel" }
    expect(output).to include('<button')
    expect(output).to include('data-wabi--dialog-target="closeTrigger"')
  end

  it "composes into a full drawer" do
    composed = Class.new(Phlex::HTML) do
      def view_template
        render Components::UI::Drawer.new(side: :right) do
          render Components::UI::DrawerTrigger.new { "Open" }
          render Components::UI::DrawerContent.new(side: :right) do
            render Components::UI::DrawerHeader.new do
              render Components::UI::DrawerTitle.new       { "Settings" }
              render Components::UI::DrawerDescription.new { "Tune your prefs." }
            end
            render Components::UI::DrawerFooter.new do
              render Components::UI::DrawerClose.new { "Close" }
            end
          end
        end
      end
    end.new.call

    expect(composed).to include('data-controller="wabi--dialog"')
    expect(composed).to include('data-wabi--dialog-target="trigger"')
    expect(composed).to include('data-wabi--dialog-target="content"')
    expect(composed).to include("Settings")
  end
end
