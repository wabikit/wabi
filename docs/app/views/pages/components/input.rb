# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Input < Views::Base
        SOURCE_PATHS = %w[app/components/ui/input.rb].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Input", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Input" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add input",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Input.new(name: "email", placeholder: "you@example.com", type: "email")
              RUBY
                render ::Components::UI::Input.new(name: "email", placeholder: "you@example.com", type: "email")
              end

              h2(id: "invalid", class: "text-2xl font-semibold mt-8 mb-4") { "Invalid state" }
              p(class: "text-sm text-muted-foreground mb-4") do
                "Pass invalid: true to render aria-invalid=\"true\", which assistive tech announces " \
                "and styles can target via aria-[invalid]:."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Input.new(name: "email", value: "not-an-email", type: "email", invalid: true, aria_label: "Email")
              RUBY
                render ::Components::UI::Input.new(name: "email", value: "not-an-email", type: "email", invalid: true, aria_label: "Email")
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}",
                   class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "native <input> element — full browser keyboard support out of the box." }
                li { "focus-visible:ring keeps focus state visible without click pollution." }
                li { "disabled state via disabled:opacity-50 + disabled:cursor-not-allowed." }
                li { "inherits type-specific affordances (email keyboard on mobile, etc.)." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "input", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
