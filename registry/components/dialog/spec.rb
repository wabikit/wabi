# frozen_string_literal: true

require "wabi"
require_relative "../button/button"
require_relative "dialog"
require_relative "dialog_trigger"
require_relative "dialog_content"
require_relative "dialog_header"
require_relative "dialog_title"
require_relative "dialog_description"
require_relative "dialog_footer"
require_relative "dialog_cancel"
require_relative "dialog_action"

RSpec.describe "Dialog composition" do
  it "wires the root with the Stimulus controller and open/modal values" do
    output = Components::UI::Dialog.new.call { "" }
    expect(output).to include('data-controller="wabi--dialog"')
    expect(output).to include('data-wabi--dialog-modal-value="true"')
  end

  it "carries portal-value true by default" do
    output = Components::UI::Dialog.new.call
    expect(output).to include('data-wabi--dialog-portal-value="true"')
  end

  it "allows portal: false to keep v0.4 in-tree behavior" do
    output = Components::UI::Dialog.new(portal: false).call
    expect(output).to include('data-wabi--dialog-portal-value="false"')
  end

  it "renders DialogTrigger as a <button> with the trigger target" do
    output = Components::UI::DialogTrigger.new.call { "Open" }
    expect(output).to include('<button')
    expect(output).to include('data-wabi--dialog-target="trigger"')
    expect(output).to include("Open")
  end

  it "renders DialogContent with backdrop + positioner > content (role=dialog)" do
    output = Components::UI::DialogContent.new.call { "" }
    expect(output).to include('data-wabi--dialog-target="backdrop"')
    expect(output).to include('data-wabi--dialog-target="positioner"')
    expect(output).to include('data-wabi--dialog-target="content"')
    expect(output).to include('role="dialog"')
    expect(output).to include('aria-modal="true"')
  end

  it "DialogContent defaults to role=dialog and data-wabi--dialog-alert=false" do
    output = Components::UI::DialogContent.new.call { "" }
    expect(output).to include('role="dialog"')
    expect(output).not_to include('role="alertdialog"')
    expect(output).to include('data-wabi--dialog-alert="false"')
  end

  it "DialogContent with alert: true renders role=alertdialog and signals the controller" do
    output = Components::UI::DialogContent.new(alert: true).call { "" }
    expect(output).to include('role="alertdialog"')
    expect(output).not_to include('role="dialog"')
    expect(output).to include('data-wabi--dialog-alert="true"')
  end

  it "starts backdrop and content with data-state=closed, content also inert" do
    # v0.1.x: visibility moved off the `hidden` attribute and onto `data-state`.
    # Closed state -> CSS opacity-0 (transition runs); the controller toggles
    # `inert` on the content to keep it out of tab order + accessibility tree.
    # Positioner is `pointer-events-none` so it never blocks clicks even when
    # the dialog is closed -- no `hidden` needed there.
    output = Components::UI::DialogContent.new.call { "" }
    expect(output).to include('data-wabi--dialog-target="backdrop" data-state="closed"')
    expect(output).to include('data-state="closed" data-wabi--dialog-target="content"')
    expect(output).to match(/data-wabi--dialog-target="content"[^>]*\binert\b/)
  end

  it "DialogContent includes motion-reduce:transition-none for prefers-reduced-motion support" do
    output = Components::UI::DialogContent.new.call { "" }
    expect(output).to include("motion-reduce:transition-none")
  end

  it "renders DialogTitle as <h2> with the title target" do
    output = Components::UI::DialogTitle.new.call { "Confirm" }
    expect(output).to include('<h2')
    expect(output).to include('data-wabi--dialog-target="title"')
    expect(output).to include("Confirm")
  end

  it "renders DialogDescription as <p> with the description target" do
    output = Components::UI::DialogDescription.new.call { "Are you sure?" }
    expect(output).to include('<p')
    expect(output).to include('data-wabi--dialog-target="description"')
    expect(output).to include("Are you sure?")
  end

  it "renders DialogCancel as an outlined Button tagged as closeTrigger" do
    output = Components::UI::DialogCancel.new.call { "Cancel" }
    expect(output).to include('<button')
    expect(output).to include('data-wabi--dialog-target="closeTrigger"')
    expect(output).to include("Cancel")
  end

  it "renders DialogAction as a primary Button (no auto-close wiring)" do
    output = Components::UI::DialogAction.new.call { "Delete" }
    expect(output).to include('<button')
    expect(output).to include("Delete")
    expect(output).not_to include("closeTrigger")
  end

  it "composes into a full dialog" do
    composed = Class.new(Phlex::HTML) do
      def view_template
        render Components::UI::Dialog.new do
          render Components::UI::DialogTrigger.new { "Open dialog" }
          render Components::UI::DialogContent.new do
            render Components::UI::DialogHeader.new do
              render Components::UI::DialogTitle.new       { "Delete account" }
              render Components::UI::DialogDescription.new { "This action cannot be undone." }
            end
            render Components::UI::DialogFooter.new do
              render Components::UI::DialogCancel.new { "Cancel" }
              render Components::UI::DialogAction.new(appearance: :destructive) { "Delete" }
            end
          end
        end
      end
    end.new.call

    expect(composed).to include('data-controller="wabi--dialog"')
    expect(composed).to include('data-wabi--dialog-target="trigger"')
    expect(composed).to include('data-wabi--dialog-target="content"')
    expect(composed).to include("Delete account")
    expect(composed).to include("This action cannot be undone.")
  end
end
