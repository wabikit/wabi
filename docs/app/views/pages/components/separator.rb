# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Separator < Views::Base
        SOURCE_PATHS = %w[app/components/ui/separator.rb].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Separator", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Separator" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add separator",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                div(class: "flex flex-col gap-2 text-sm") do
                  span { "Above the line" }
                  render Components::UI::Separator.new
                  span { "Below the line" }
                end
              RUBY
                div(class: "flex flex-col gap-2 text-sm") do
                  span { "Above the line" }
                  render ::Components::UI::Separator.new
                  span { "Below the line" }
                end
              end

              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                div(class: "flex items-center gap-2 text-sm") do
                  span { "Left" }
                  render Components::UI::Separator.new(orientation: :vertical, class: "h-4")
                  span { "Right" }
                end
              RUBY
                div(class: "flex items-center gap-2 text-sm") do
                  span { "Left" }
                  render ::Components::UI::Separator.new(orientation: :vertical, class: "h-4")
                  span { "Right" }
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
                li { 'role="separator" with aria-orientation reflecting horizontal or vertical — only when decorative: false is passed.' }
                li { 'decorative separators (purely visual) default to decorative: true, which renders role="none" and no aria-orientation.' }
                li { 'semantic separators (between distinct content groups) pass decorative: false to activate role="separator" for screen-reader navigation.' }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "separator", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
