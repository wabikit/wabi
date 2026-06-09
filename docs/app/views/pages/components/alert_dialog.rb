# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class AlertDialog < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/alert_dialog.rb
          app/components/ui/alert_dialog_trigger.rb
          app/components/ui/alert_dialog_content.rb
          app/components/ui/alert_dialog_header.rb
          app/components/ui/alert_dialog_title.rb
          app/components/ui/alert_dialog_description.rb
          app/components/ui/alert_dialog_footer.rb
          app/components/ui/alert_dialog_cancel.rb
          app/components/ui/alert_dialog_action.rb
          app/javascript/controllers/wabi/alert_dialog_controller.js
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Alert Dialog", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Alert Dialog" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add alert_dialog\nbin/importmap pin @zag-js/dialog\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/dialog and @zag-js/vanilla at version 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only downloads the main entry and leaves submodule imports unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::AlertDialog.new do
                  render Components::UI::AlertDialogTrigger.new(class: "inline-flex h-10 px-4 items-center rounded-md border border-input") { "Delete account" }
                  render Components::UI::AlertDialogContent.new do
                    render Components::UI::AlertDialogHeader.new do
                      render Components::UI::AlertDialogTitle.new { "Are you absolutely sure?" }
                      render Components::UI::AlertDialogDescription.new { "This permanently deletes your account and cannot be undone." }
                    end
                    render Components::UI::AlertDialogFooter.new do
                      render Components::UI::AlertDialogCancel.new { "Cancel" }
                      render Components::UI::AlertDialogAction.new(appearance: :destructive) { "Delete" }
                    end
                  end
                end
              RUBY
                render ::Components::UI::AlertDialog.new do
                  render ::Components::UI::AlertDialogTrigger.new(class: "inline-flex h-10 px-4 items-center rounded-md border border-input") { "Delete account" }
                  render ::Components::UI::AlertDialogContent.new do
                    render ::Components::UI::AlertDialogHeader.new do
                      render ::Components::UI::AlertDialogTitle.new { "Are you absolutely sure?" }
                      render ::Components::UI::AlertDialogDescription.new { "This permanently deletes your account and cannot be undone." }
                    end
                    render ::Components::UI::AlertDialogFooter.new do
                      render ::Components::UI::AlertDialogCancel.new { "Cancel" }
                      render ::Components::UI::AlertDialogAction.new(appearance: :destructive) { "Delete" }
                    end
                  end
                end
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}", class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "role=\"alertdialog\" + aria-modal=\"true\"; title/description wired via aria-labelledby/aria-describedby." }
                li { "Does not dismiss on outside click — requires an explicit action (Cancel or Confirm)." }
                li { "Escape closes the dialog." }
                li { "Initial focus moves to the Cancel button on open; restored to trigger on close." }
                li { "Focus trap keeps Tab inside the dialog while open." }
                li { "Content carries inert when closed — keeps out of tab order + a11y tree." }
                li { "Scroll lock applied to <body> while modal is open." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "alert_dialog", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
