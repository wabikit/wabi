# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Collapsible < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/collapsible.rb
          app/components/ui/collapsible_trigger.rb
          app/components/ui/collapsible_content.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Collapsible", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Collapsible" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(source: "bin/rails g wabi:add collapsible", language: "shell")

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Collapsible.new do
                  render Components::UI::CollapsibleTrigger.new(class: "w-full") { "Toggle details" }
                  render Components::UI::CollapsibleContent.new do
                    p(class: "py-2 text-sm text-muted-foreground") { "Hidden content revealed with a height animation." }
                  end
                end
              RUBY
                render ::Components::UI::Collapsible.new do
                  render ::Components::UI::CollapsibleTrigger.new(class: "w-full") { "Toggle details" }
                  render ::Components::UI::CollapsibleContent.new do
                    p(class: "py-2 text-sm text-muted-foreground") { "Hidden content revealed with a height animation." }
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
                li { "Trigger exposes aria-expanded and aria-controls; content has a matching id." }
                li { "Height animation respects prefers-reduced-motion." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "collapsible", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
