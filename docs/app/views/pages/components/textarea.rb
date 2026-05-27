# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Textarea < Views::Base
        SOURCE_PATHS = %w[app/components/ui/textarea.rb].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Textarea", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Textarea" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add textarea",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Textarea.new(name: "feedback", placeholder: "What's on your mind?", rows: 4)
              RUBY
                render ::Components::UI::Textarea.new(name: "feedback", placeholder: "What's on your mind?", rows: 4)
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}",
                   class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "native <textarea> element; full browser keyboard support." }
                li { "focus-visible:ring kept clean of click pollution." }
                li { "disabled state via disabled:opacity-50." }
                li { "resize behavior follows the native CSS resize property (vertical by default)." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "textarea", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
