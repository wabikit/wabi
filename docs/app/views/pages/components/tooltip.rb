# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Tooltip < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/tooltip.rb
          app/components/ui/tooltip_trigger.rb
          app/components/ui/tooltip_content.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Tooltip", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Tooltip" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add tooltip\nbin/importmap pin @zag-js/tooltip\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Tooltip.new do
                  render Components::UI::TooltipTrigger.new(class: "...") { "Hover me" }
                  render Components::UI::TooltipContent.new { "Helpful hint displayed on hover or focus." }
                end
              RUBY
                render ::Components::UI::Tooltip.new do
                  render ::Components::UI::TooltipTrigger.new(
                    class: "inline-flex items-center justify-center rounded-md text-sm font-medium " \
                           "border border-input bg-background hover:bg-accent hover:text-accent-foreground " \
                           "h-10 px-4 py-2"
                  ) { "Hover me" }
                  render ::Components::UI::TooltipContent.new { "Helpful hint displayed on hover or focus." }
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
                li { "role=\"tooltip\" on the content panel; aria-describedby set on the trigger element." }
                li { "The tooltip shows on hover AND keyboard focus — pure-hover tooltips are inaccessible to keyboard users." }
                li { "Escape dismisses an open tooltip immediately." }
                li { "Delay timing (open/close) is configurable to balance information density vs. accidental triggers." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "tooltip", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
