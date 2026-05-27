# frozen_string_literal: true

module Views
  module Pages
    module Components
      class Dialog < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/dialog.rb
          app/components/ui/dialog_trigger.rb
          app/components/ui/dialog_content.rb
          app/components/ui/dialog_header.rb
          app/components/ui/dialog_footer.rb
          app/components/ui/dialog_title.rb
          app/components/ui/dialog_description.rb
          app/components/ui/dialog_action.rb
          app/components/ui/dialog_cancel.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Dialog", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Dialog" }
              p(class: "text-muted-foreground mb-8") do
                "Modal dialog with backdrop, focus trap, scroll lock, click-outside and Escape dismiss. " \
                "Built on @zag-js/dialog."
              end

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add dialog\nbin/importmap pin @zag-js/dialog\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/dialog and @zag-js/vanilla at version 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only downloads the main entry and leaves submodule imports unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Dialog.new do
                  render Components::UI::DialogTrigger.new(class: "...") { "Open dialog" }
                  render Components::UI::DialogContent.new do
                    render Components::UI::DialogHeader.new do
                      render Components::UI::DialogTitle.new       { "Delete account" }
                      render Components::UI::DialogDescription.new { "This cannot be undone." }
                    end
                    render Components::UI::DialogFooter.new do
                      render Components::UI::DialogCancel.new { "Cancel" }
                      render Components::UI::DialogAction.new(appearance: :destructive) { "Delete" }
                    end
                  end
                end
              RUBY
                render ::Components::UI::Dialog.new do
                  render ::Components::UI::DialogTrigger.new(
                    class: "inline-flex items-center justify-center rounded-md text-sm font-medium " \
                           "bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2"
                  ) { "Open dialog" }
                  render ::Components::UI::DialogContent.new do
                    render ::Components::UI::DialogHeader.new do
                      render ::Components::UI::DialogTitle.new       { "Delete account" }
                      render ::Components::UI::DialogDescription.new { "This action cannot be undone." }
                    end
                    render ::Components::UI::DialogFooter.new do
                      render ::Components::UI::DialogCancel.new { "Cancel" }
                      render ::Components::UI::DialogAction.new(appearance: :destructive, data: { action: "click->wabi--dialog#close" }) { "Delete" }
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
                li { "role=\"dialog\" + aria-modal=\"true\"; title/description wired via aria-labelledby/aria-describedby." }
                li { "Initial focus moves into the dialog on open; restored to trigger on close." }
                li { "Focus trap keeps Tab inside the dialog while open." }
                li { "Backdrop click and Escape close the dialog (configurable via Zag opts)." }
                li { "Content carries inert when closed — keeps out of tab order + a11y tree (Zag onOpenChange synchronous toggle)." }
                li { "Scroll lock applied to <body> while modal is open." }
              end
            end
          end
        end
      end
    end
  end
end
