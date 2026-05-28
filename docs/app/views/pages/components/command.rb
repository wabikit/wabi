# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Command < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/command.rb
          app/components/ui/command_trigger.rb
          app/components/ui/command_dialog.rb
          app/components/ui/command_input.rb
          app/components/ui/command_list.rb
          app/components/ui/command_group.rb
          app/components/ui/command_item.rb
          app/components/ui/command_empty.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Command", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Command" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add command",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Command depends on the dialog and combobox components — the generator will install " \
                "both. The @zag-js/dialog, @zag-js/combobox, and @zag-js/vanilla pins come from those " \
                "dependencies; no additional importmap pins are needed."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Command.new do
                  render Components::UI::CommandTrigger.new { "Search commands... ⌘K" }

                  render Components::UI::CommandDialog.new do
                    render Components::UI::CommandInput.new(placeholder: "Type a command or search...")
                    render Components::UI::CommandList.new(
                      items: [
                        { value: "new_file",  label: "New File",   group: "File", shortcut: "⌘N" },
                        { value: "open_file", label: "Open File…", group: "File", shortcut: "⌘O" },
                        { value: "save_file", label: "Save File",  group: "File", shortcut: "⌘S" },
                        { value: "settings",  label: "Settings",   group: "App",  shortcut: "⌘," },
                        { value: "logout",    label: "Logout",     group: "App"                    },
                      ]
                    ) do
                      render Components::UI::CommandEmpty.new { "No results found." }
                    end
                  end
                end
              RUBY
                render ::Components::UI::Command.new do
                  render ::Components::UI::CommandTrigger.new { "Search commands... ⌘K" }

                  render ::Components::UI::CommandDialog.new do
                    render ::Components::UI::CommandInput.new(placeholder: "Type a command or search...")
                    render ::Components::UI::CommandList.new(
                      items: [
                        { value: "new_file",  label: "New File",   group: "File", shortcut: "⌘N" },
                        { value: "open_file", label: "Open File…", group: "File", shortcut: "⌘O" },
                        { value: "save_file", label: "Save File",  group: "File", shortcut: "⌘S" },
                        { value: "settings",  label: "Settings",   group: "App",  shortcut: "⌘," },
                        { value: "logout",    label: "Logout",     group: "App"                    },
                      ]
                    ) do
                      render ::Components::UI::CommandEmpty.new { "No results found." }
                    end
                  end
                end
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}",
                   class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { 'Command is a modal dialog (role="dialog", aria-modal="true") containing an autocomplete combobox.' }
                li { "The visible list items get role=\"option\" + data-highlighted from Zag's combobox machine; arrow keys navigate, Enter selects." }
                li { "⌘K is NOT bound by default — callers add their own keybinding (e.g. a Stimulus controller that listens for keydown and calls the dialog's open() action)." }
                li { "Selecting an item dispatches wabi--combobox:change, which a small wabi--command bridge controller forwards to the dialog's close()." }
                li { "When closed, the dialog content is inert + pointer-events-none so it's skipped by tab order and click events." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "command", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
