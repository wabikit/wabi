# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Combobox < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/combobox.rb
          app/components/ui/combobox_label.rb
          app/components/ui/combobox_control.rb
          app/components/ui/combobox_input.rb
          app/components/ui/combobox_trigger.rb
          app/components/ui/combobox_positioner.rb
          app/components/ui/combobox_content.rb
          app/components/ui/combobox_item.rb
          app/components/ui/combobox_item_indicator.rb
        ].freeze

        FRAMEWORKS = [
          { value: "rails",   label: "Ruby on Rails" },
          { value: "django",  label: "Django" },
          { value: "phoenix", label: "Phoenix", disabled: true },
          { value: "express", label: "Express" },
          { value: "fastapi", label: "FastAPI" },
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Combobox", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Combobox" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add combobox\nbin/importmap pin @zag-js/combobox\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/combobox and @zag-js/vanilla at version 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only downloads the main entry and leaves submodule imports unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                items = [
                  { value: "rails",   label: "Ruby on Rails" },
                  { value: "django",  label: "Django" },
                  { value: "phoenix", label: "Phoenix", disabled: true },
                  { value: "express", label: "Express" },
                  { value: "fastapi", label: "FastAPI" },
                ]

                render Components::UI::Combobox.new(name: "framework", items: items, placeholder: "Pick a framework...") do
                  render Components::UI::ComboboxLabel.new { "Framework" }
                  render Components::UI::ComboboxControl.new do
                    render Components::UI::ComboboxInput.new
                    render Components::UI::ComboboxTrigger.new
                  end
                  render Components::UI::ComboboxPositioner.new do
                    render Components::UI::ComboboxContent.new do
                      items.each do |item|
                        render Components::UI::ComboboxItem.new(value: item[:value], disabled: item[:disabled]) { item[:label] }
                      end
                    end
                  end
                end
              RUBY
                render ::Components::UI::Combobox.new(name: "framework", items: FRAMEWORKS, placeholder: "Pick a framework...") do
                  render ::Components::UI::ComboboxLabel.new { "Framework" }
                  render ::Components::UI::ComboboxControl.new do
                    render ::Components::UI::ComboboxInput.new
                    render ::Components::UI::ComboboxTrigger.new
                  end
                  render ::Components::UI::ComboboxPositioner.new do
                    render ::Components::UI::ComboboxContent.new do
                      FRAMEWORKS.each do |item|
                        render ::Components::UI::ComboboxItem.new(value: item[:value], disabled: item[:disabled]) { item[:label] }
                      end
                    end
                  end
                end
              end

              h2(id: "async", class: "text-2xl font-semibold mt-8 mb-4") { "Async (server-rendered items)" }
              p(class: "text-sm text-muted-foreground mb-4") do
                "Pass url: to fetch server-rendered ComboboxItem fragments on each keystroke. " \
                "The controller debounces input, aborts stale requests, and swaps items into the content."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Combobox.new(
                  name: "framework_async",
                  items: [],
                  placeholder: "Search frameworks...",
                  url: "/docs/components/combobox/search",
                  param: "q",
                  debounce: 250,
                  min_length: 1,
                ) do
                  render Components::UI::ComboboxLabel.new { "Framework (async)" }
                  render Components::UI::ComboboxControl.new do
                    render Components::UI::ComboboxInput.new
                    render Components::UI::ComboboxTrigger.new
                  end
                  render Components::UI::ComboboxPositioner.new do
                    render Components::UI::ComboboxContent.new do
                      render Components::UI::ComboboxLoading.new { "Loading..." }
                      render Components::UI::ComboboxError.new { "Couldn't load results. Try again." }
                    end
                  end
                end
              RUBY
                render ::Components::UI::Combobox.new(
                  name: "framework_async",
                  items: [],
                  placeholder: "Search frameworks...",
                  url: "/docs/components/combobox/search",
                  param: "q",
                  debounce: 250,
                  min_length: 1,
                ) do
                  render ::Components::UI::ComboboxLabel.new { "Framework (async)" }
                  render ::Components::UI::ComboboxControl.new do
                    render ::Components::UI::ComboboxInput.new
                    render ::Components::UI::ComboboxTrigger.new
                  end
                  render ::Components::UI::ComboboxPositioner.new do
                    render ::Components::UI::ComboboxContent.new do
                      render ::Components::UI::ComboboxLoading.new { "Loading..." }
                      render ::Components::UI::ComboboxError.new { "Couldn't load results. Try again." }
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
                li { 'role="combobox" with aria-expanded, aria-controls, aria-activedescendant managed by Zag.' }
                li { "Arrow Down / Up move highlight through filtered items; Enter selects the highlighted item." }
                li { "Escape closes the listbox and clears the highlight; Home / End jump to first / last item." }
                li { "Typing filters the collection in real time via the configured itemToString predicate." }
                li { "Trigger button is exposed as a separate control with aria-haspopup=\"listbox\"." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "combobox", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
