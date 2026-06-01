# frozen_string_literal: true

require "wabi"
require_relative "../button/button"
require_relative "alert_dialog"
require_relative "alert_dialog_trigger"
require_relative "alert_dialog_content"
require_relative "alert_dialog_header"
require_relative "alert_dialog_title"
require_relative "alert_dialog_description"
require_relative "alert_dialog_footer"
require_relative "alert_dialog_cancel"
require_relative "alert_dialog_action"

RSpec.describe Components::UI::AlertDialog do
  it "wires the wabi--alert-dialog controller on the root" do
    output = described_class.new.call
    expect(output).to include('data-controller="wabi--alert-dialog"')
  end

  it "renders content with role=alertdialog and aria-modal" do
    output = Components::UI::AlertDialogContent.new.call { "body" }
    expect(output).to include('role="alertdialog"')
    expect(output).to include('aria-modal="true"')
  end

  it "tags the cancel button as both closeTrigger and cancel targets" do
    output = Components::UI::AlertDialogCancel.new.call { "Cancel" }
    expect(output).to include('closeTrigger cancel')
    expect(output).to include("Cancel")
  end

  it "renders title and description parts" do
    title = Components::UI::AlertDialogTitle.new.call { "Are you sure?" }
    desc  = Components::UI::AlertDialogDescription.new.call { "This cannot be undone." }
    expect(title).to include("Are you sure?")
    expect(desc).to include("This cannot be undone.")
  end

  it "composes trigger + content" do
    composition = Class.new(Phlex::HTML) do
      def view_template
        render Components::UI::AlertDialog.new do
          render Components::UI::AlertDialogTrigger.new { "Delete" }
          render Components::UI::AlertDialogContent.new do
            render Components::UI::AlertDialogHeader.new do
              render Components::UI::AlertDialogTitle.new { "Delete account?" }
              render Components::UI::AlertDialogDescription.new { "Permanent." }
            end
            render Components::UI::AlertDialogFooter.new do
              render Components::UI::AlertDialogCancel.new { "Cancel" }
              render Components::UI::AlertDialogAction.new { "Delete" }
            end
          end
        end
      end
    end
    output = composition.new.call
    expect(output).to include("Delete account?")
    expect(output).to include("Cancel")
    expect(output).to include('role="alertdialog"')
  end
end
