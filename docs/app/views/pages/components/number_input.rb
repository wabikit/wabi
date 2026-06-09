# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class NumberInput < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/number_input.rb
          app/javascript/controllers/wabi/number_input_controller.js
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Number Input", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Number Input" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add number_input",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::NumberInput.new(name: "quantity", value: 1, min: 0, aria_label: "Quantity", class: "w-44")
              RUBY
                render ::Components::UI::NumberInput.new(name: "quantity", value: 1, min: 0, aria_label: "Quantity", class: "w-44")
              end

              h2(id: "example-currency", class: "text-2xl font-semibold mt-8 mb-4") { "Currency" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::NumberInput.new(
                  name: "price", value: 19.99, step: 0.01, precision: 2,
                  format: :currency, currency: "USD", aria_label: "Price", class: "w-44"
                )
              RUBY
                render ::Components::UI::NumberInput.new(
                  name: "price", value: 19.99, step: 0.01, precision: 2,
                  format: :currency, currency: "USD", aria_label: "Price", class: "w-44"
                )
              end

              h2(id: "example-percent", class: "text-2xl font-semibold mt-8 mb-4") { "Percent" }
              p(class: "text-muted-foreground mb-4 text-sm") do
                plain "With "
                code(class: "font-mono text-foreground") { "format: :percent" }
                plain " the value is a ratio (Intl semantics): "
                code(class: "font-mono text-foreground") { "value: 0.25" }
                plain " displays as 25%."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::NumberInput.new(
                  name: "discount", value: 0.25, min: 0, max: 1, step: 0.05,
                  format: :percent, aria_label: "Discount", class: "w-44"
                )
              RUBY
                render ::Components::UI::NumberInput.new(
                  name: "discount", value: 0.25, min: 0, max: 1, step: 0.05,
                  format: :percent, aria_label: "Discount", class: "w-44"
                )
              end

              h2(id: "example-bounds", class: "text-2xl font-semibold mt-8 mb-4") { "Min / max / step" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::NumberInput.new(name: "rating", value: 3, min: 0, max: 5, step: 1, aria_label: "Rating", class: "w-44")
              RUBY
                render ::Components::UI::NumberInput.new(name: "rating", value: 3, min: 0, max: 5, step: 1, aria_label: "Rating", class: "w-44")
              end

              h2(id: "example-invalid", class: "text-2xl font-semibold mt-8 mb-4") { "Invalid" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::NumberInput.new(name: "qty", value: 2, invalid: true, aria_label: "Quantity", class: "w-44")
              RUBY
                render ::Components::UI::NumberInput.new(name: "qty", value: 2, invalid: true, aria_label: "Quantity", class: "w-44")
              end

              h2(id: "example-sizes", class: "text-2xl font-semibold mt-8 mb-4") { "Sizes" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::NumberInput.new(name: "a", value: 1, size: :sm, aria_label: "Small quantity", class: "w-40")
                render Components::UI::NumberInput.new(name: "b", value: 1, size: :md, aria_label: "Medium quantity", class: "w-40")
                render Components::UI::NumberInput.new(name: "c", value: 1, size: :lg, aria_label: "Large quantity", class: "w-40")
              RUBY
                div(class: "flex flex-col gap-3") do
                  render ::Components::UI::NumberInput.new(name: "a", value: 1, size: :sm, aria_label: "Small quantity", class: "w-40")
                  render ::Components::UI::NumberInput.new(name: "b", value: 1, size: :md, aria_label: "Medium quantity", class: "w-40")
                  render ::Components::UI::NumberInput.new(name: "c", value: 1, size: :lg, aria_label: "Large quantity", class: "w-40")
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
                li { "The inner input is a role=spinbutton with aria-valuemin/max/now managed by Zag." }
                li { "Increment and decrement are real <button>s with accessible labels." }
                li { "Keyboard: ↑/↓ adjust by step, PageUp/PageDown by a larger step, Home/End jump to min/max." }
                li { "For form labeling, wrap the field in a <label>, or pass a stable id: — Zag composes the input id as number-input:<id>:input." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "number_input", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
