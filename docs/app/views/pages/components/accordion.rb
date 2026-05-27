# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Accordion < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/accordion.rb
          app/components/ui/accordion_item.rb
          app/components/ui/accordion_trigger.rb
          app/components/ui/accordion_content.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Accordion", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Accordion" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add accordion\nbin/importmap pin @zag-js/accordion\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/accordion and @zag-js/vanilla at version 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only downloads the main entry and leaves submodule imports unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Accordion.new do
                  render Components::UI::AccordionItem.new(value: "q1") do
                    render Components::UI::AccordionTrigger.new(value: "q1") { "Is it accessible?" }
                    render Components::UI::AccordionContent.new(value: "q1") do
                      "Yes. Keyboard navigation, ARIA roles, and aria-expanded are all wired by the Zag machine."
                    end
                  end
                  render Components::UI::AccordionItem.new(value: "q2") do
                    render Components::UI::AccordionTrigger.new(value: "q2") { "Is it styled?" }
                    render Components::UI::AccordionContent.new(value: "q2") do
                      "Yes. Tailwind utility classes with full theming support via CSS variables."
                    end
                  end
                  render Components::UI::AccordionItem.new(value: "q3") do
                    render Components::UI::AccordionTrigger.new(value: "q3") { "Is it animated?" }
                    render Components::UI::AccordionContent.new(value: "q3") do
                      "Yes. Height transitions use a CSS grid-rows trick — no keyframes, no extra dependencies."
                    end
                  end
                end
              RUBY
                render ::Components::UI::Accordion.new do
                  render ::Components::UI::AccordionItem.new(value: "q1") do
                    render ::Components::UI::AccordionTrigger.new(value: "q1") { "Is it accessible?" }
                    render ::Components::UI::AccordionContent.new(value: "q1") do
                      "Yes. Keyboard navigation, ARIA roles, and aria-expanded are all wired by the Zag machine."
                    end
                  end
                  render ::Components::UI::AccordionItem.new(value: "q2") do
                    render ::Components::UI::AccordionTrigger.new(value: "q2") { "Is it styled?" }
                    render ::Components::UI::AccordionContent.new(value: "q2") do
                      "Yes. Tailwind utility classes with full theming support via CSS variables."
                    end
                  end
                  render ::Components::UI::AccordionItem.new(value: "q3") do
                    render ::Components::UI::AccordionTrigger.new(value: "q3") { "Is it animated?" }
                    render ::Components::UI::AccordionContent.new(value: "q3") do
                      "Yes. Height transitions use a CSS grid-rows trick — no keyframes, no extra dependencies."
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
                li { "Each AccordionContent has role=\"region\" and aria-labelledby pointing to its trigger." }
                li { "aria-expanded on the trigger reflects open/closed state." }
                li { "Up/Down arrows move focus between triggers; Home/End jump to first/last; Enter or Space toggles." }
                li { "single mode (default) closes other items on open; multiple mode permits any combination." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "accordion", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
