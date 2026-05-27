# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Label < Views::Base
        SOURCE_PATHS = %w[app/components/ui/label.rb].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Label", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Label" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add label",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                div(class: "grid gap-1.5") do
                  render Components::UI::Label.new(for_: "email") { "Email" }
                  render Components::UI::Input.new(id: "email", name: "email", type: "email")
                end
              RUBY
                div(class: "grid gap-1.5") do
                  render ::Components::UI::Label.new(for_: "email") { "Email" }
                  render ::Components::UI::Input.new(id: "email", name: "email", type: "email")
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
                li { 'native <label for="..."> association — clicking the label focuses or activates the bound input.' }
                li { "the for_: kwarg maps to the HTML for attribute and must match the input's id." }
                li { "for screen readers, the label text is announced when the input is focused." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "label", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
