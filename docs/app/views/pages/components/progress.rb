# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Progress < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/progress.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Progress", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Progress" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add progress",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Progress.new(value: 60, class: "max-w-md")
              RUBY
                render ::Components::UI::Progress.new(value: 60, class: "max-w-md")
              end

              h2(id: "labeled", class: "text-2xl font-semibold mt-8 mb-4") { "Labeled progress" }
              p(class: "text-muted-foreground mb-4 text-sm") do
                "Pass a contextual aria_label: so screen readers announce what is progressing. " \
                "max: defaults to 100 but can be set to any scale."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Progress.new(
                  value: 70,
                  max: 100,
                  aria_label: "File upload progress",
                  class: "max-w-md"
                )
              RUBY
                render ::Components::UI::Progress.new(
                  value: 70,
                  max: 100,
                  aria_label: "File upload progress",
                  class: "max-w-md"
                )
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}",
                   class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "Renders a <div> with role=\"progressbar\", aria-valuemin, aria-valuemax, and aria-valuenow." }
                li { "Pass a descriptive label via aria_label: or aria_labelledby: for screen reader context." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "progress", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
