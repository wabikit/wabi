# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class TagsInput < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/tags_input.rb
          app/components/ui/tags_input_control.rb
          app/components/ui/tags_input_input.rb
          app/components/ui/tags_input_error.rb
          app/components/ui/tags_input_label.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Tags Input", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Tags Input" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add tags_input", language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::TagsInput.new(name: "tags", value: %w[ruby rails], placeholder: "Add a tag…")
              RUBY
                render ::Components::UI::TagsInput.new(name: "tags", value: %w[ruby rails], placeholder: "Add a tag…")
              end

              h2(id: "max-tags", class: "text-2xl font-semibold mt-8 mb-4") { "Limiting tags" }
              p(class: "text-muted-foreground mb-4 text-sm") do
                plain "Cap the number of tags with "
                code(class: "font-mono text-foreground") { "max:" }
                plain ". Pass "
                code(class: "font-mono text-foreground") { "editable: false" }
                plain " to prevent editing existing tags in place."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::TagsInput.new(name: "topics", value: %w[ruby rails], max: 3, editable: false, placeholder: "Up to 3 topics…")
              RUBY
                render ::Components::UI::TagsInput.new(name: "topics", value: %w[ruby rails], max: 3, editable: false, placeholder: "Up to 3 topics…")
              end

              h2(id: "disabled", class: "text-2xl font-semibold mt-8 mb-4") { "Disabled" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::TagsInput.new(name: "tags", value: %w[ruby rails], disabled: true)
              RUBY
                render ::Components::UI::TagsInput.new(name: "tags", value: %w[ruby rails], disabled: true)
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}",
                   class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "Backspace on an empty input removes the last tag; arrow keys move between tags." }
                li { "Each tag exposes a labelled delete button." }
                li { "Submits as an array: params[:tags] # => [\"ruby\", \"rails\"]." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "tags_input", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
