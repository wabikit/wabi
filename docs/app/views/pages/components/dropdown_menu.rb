# frozen_string_literal: true

module Views
  module Pages
    module Components
      class DropdownMenu < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/dropdown_menu.rb
          app/components/ui/dropdown_menu_trigger.rb
          app/components/ui/dropdown_menu_content.rb
          app/components/ui/dropdown_menu_item.rb
          app/components/ui/dropdown_menu_sub.rb
          app/components/ui/dropdown_menu_sub_trigger.rb
          app/components/ui/dropdown_menu_sub_content.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "DropdownMenu") do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "DropdownMenu" }
              p(class: "text-muted-foreground mb-8") do
                "Floating menu with keyboard navigation, type-ahead, click/Escape dismiss, " \
                "single-level submenus, and option (checkbox/radio) items."
              end

              h2(class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add dropdown_menu\nbin/importmap pin @zag-js/menu\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/menu and @zag-js/vanilla at version 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only downloads the main entry and leaves submodule imports unresolved."
              end

              h2(class: "text-2xl font-semibold mt-8 mb-4") { "Composition with submenu" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::DropdownMenu.new do
                  render Components::UI::DropdownMenuTrigger.new(class: "...") { "Actions ▾" }
                  render Components::UI::DropdownMenuContent.new do
                    render Components::UI::DropdownMenuItem.new(value: "edit") { "Edit" }
                    render Components::UI::DropdownMenuSeparator.new
                    render Components::UI::DropdownMenuSub.new do
                      render Components::UI::DropdownMenuSubTrigger.new(value: "share") { "Share" }
                      render Components::UI::DropdownMenuSubContent.new do
                        render Components::UI::DropdownMenuItem.new(value: "email") { "Email" }
                        render Components::UI::DropdownMenuItem.new(value: "slack") { "Slack" }
                      end
                    end
                  end
                end
              RUBY
                render ::Components::UI::DropdownMenu.new do
                  render ::Components::UI::DropdownMenuTrigger.new(
                    class: "inline-flex items-center justify-center rounded-md text-sm font-medium " \
                           "border border-input bg-background hover:bg-accent hover:text-accent-foreground " \
                           "h-10 px-4 py-2"
                  ) { "Actions ▾" }
                  render ::Components::UI::DropdownMenuContent.new do
                    render ::Components::UI::DropdownMenuItem.new(value: "edit") { "Edit" }
                    render ::Components::UI::DropdownMenuSeparator.new
                    render ::Components::UI::DropdownMenuSub.new do
                      render ::Components::UI::DropdownMenuSubTrigger.new(value: "share") { "Share" }
                      render ::Components::UI::DropdownMenuSubContent.new do
                        render ::Components::UI::DropdownMenuItem.new(value: "email") { "Email" }
                        render ::Components::UI::DropdownMenuItem.new(value: "slack") { "Slack" }
                      end
                    end
                  end
                end
              end

              h2(class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "role=\"menu\" + role=\"menuitem\" anatomy with aria-haspopup for nested triggers." }
                li { "Keyboard nav: ↑/↓ between items, → opens submenu, ← / Esc closes." }
                li { "Type-ahead jumps to the first item starting with the typed character." }
                li { "Content carries inert when closed — out of tab order + accessibility tree (Zag onOpenChange toggle)." }
                li { "v0.2 limit: single-level nesting (no sub-inside-a-sub). Multi-level is v0.3+ work." }
              end
            end
          end
        end
      end
    end
  end
end
