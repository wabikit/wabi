# frozen_string_literal: true

module Views
  module Pages
    module Components
      class ContextMenu < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/context_menu.rb
          app/components/ui/context_menu_trigger.rb
          app/components/ui/context_menu_content.rb
          app/components/ui/context_menu_item.rb
          app/components/ui/context_menu_label.rb
          app/components/ui/context_menu_separator.rb
          app/components/ui/context_menu_shortcut.rb
          app/components/ui/context_menu_checkbox_item.rb
          app/components/ui/context_menu_radio_group.rb
          app/components/ui/context_menu_radio_item.rb
          app/components/ui/context_menu_sub.rb
          app/components/ui/context_menu_sub_trigger.rb
          app/components/ui/context_menu_sub_content.rb
          app/javascript/controllers/wabi/context_menu_controller.js
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Context Menu", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Context Menu" }
              p(class: "text-muted-foreground mb-8") do
                "A right-click triggered floating menu with keyboard navigation, type-ahead, " \
                "Escape dismiss, checkbox and radio items, and multi-level submenus, " \
                "powered by @zag-js/menu."
              end

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add context_menu\nbin/importmap pin @zag-js/menu @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/menu and @zag-js/vanilla at version 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only downloads the main entry and leaves submodule imports unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::ContextMenu.new do
                  render Components::UI::ContextMenuTrigger.new(
                    class: "flex items-center justify-center w-64 h-24 rounded-lg border-2 border-dashed " \
                           "border-muted-foreground/40 text-sm text-muted-foreground select-none"
                  ) { "Right-click here" }
                  render Components::UI::ContextMenuContent.new do
                    render Components::UI::ContextMenuItem.new(value: "back") { "Back" }
                    render Components::UI::ContextMenuItem.new(value: "forward") { "Forward" }
                    render Components::UI::ContextMenuItem.new(value: "reload") { "Reload" }
                    render Components::UI::ContextMenuSeparator.new
                    render Components::UI::ContextMenuCheckboxItem.new(value: "bookmarks", checked: true) { "Show Bookmarks" }
                    render Components::UI::ContextMenuSeparator.new
                    render Components::UI::ContextMenuSub.new do
                      render Components::UI::ContextMenuSubTrigger.new(value: "more") { "More Tools" }
                      render Components::UI::ContextMenuSubContent.new do
                        render Components::UI::ContextMenuItem.new(value: "save") { "Save Page As…" }
                        render Components::UI::ContextMenuItem.new(value: "shortcuts") { "Keyboard Shortcuts" }
                      end
                    end
                  end
                end
              RUBY
                render ::Components::UI::ContextMenu.new do
                  render ::Components::UI::ContextMenuTrigger.new(
                    class: "flex items-center justify-center w-64 h-24 rounded-lg border-2 border-dashed " \
                           "border-muted-foreground/40 text-sm text-muted-foreground select-none"
                  ) { "Right-click here" }
                  render ::Components::UI::ContextMenuContent.new do
                    render ::Components::UI::ContextMenuItem.new(value: "back") { "Back" }
                    render ::Components::UI::ContextMenuItem.new(value: "forward") { "Forward" }
                    render ::Components::UI::ContextMenuItem.new(value: "reload") { "Reload" }
                    render ::Components::UI::ContextMenuSeparator.new
                    render ::Components::UI::ContextMenuCheckboxItem.new(value: "bookmarks", checked: true) { "Show Bookmarks" }
                    render ::Components::UI::ContextMenuSeparator.new
                    render ::Components::UI::ContextMenuSub.new do
                      render ::Components::UI::ContextMenuSubTrigger.new(value: "more") { "More Tools" }
                      render ::Components::UI::ContextMenuSubContent.new do
                        render ::Components::UI::ContextMenuItem.new(value: "save") { "Save Page As…" }
                        render ::Components::UI::ContextMenuItem.new(value: "shortcuts") { "Keyboard Shortcuts" }
                      end
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
                li { "role=\"menu\" + role=\"menuitem\" anatomy with aria-haspopup for nested triggers." }
                li { "Opens on right-click (contextmenu event); keyboard: ↑/↓ between items, → opens submenu, ← / Esc closes." }
                li { "Type-ahead jumps to the first item starting with the typed character." }
                li { "Content carries inert when closed — out of tab order and accessibility tree (Zag onOpenChange toggle)." }
                li { "Checkbox items use role=\"menuitemcheckbox\" with aria-checked toggled by the controller." }
                li { "Radio items use role=\"menuitemradio\" within a role=\"group\"; selecting one unselects siblings in the group." }
              end
            end
          end
        end
      end
    end
  end
end
