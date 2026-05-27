# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Popover < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/popover.rb
          app/components/ui/popover_trigger.rb
          app/components/ui/popover_content.rb
          app/components/ui/popover_close.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Popover", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Popover" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add popover\nbin/importmap pin @zag-js/popover\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/popover and @zag-js/vanilla at version 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only downloads the main entry and leaves submodule imports unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Popover.new do
                  render Components::UI::PopoverTrigger.new(class: "...") { "More info" }
                  render Components::UI::PopoverContent.new do
                    p(class: "text-sm") { "This is a floating panel anchored to the trigger." }
                    render Components::UI::PopoverClose.new { "Close" }
                  end
                end
              RUBY
                render ::Components::UI::Popover.new do
                  render ::Components::UI::PopoverTrigger.new(
                    class: "inline-flex items-center justify-center rounded-md text-sm font-medium " \
                           "border border-input bg-background hover:bg-accent hover:text-accent-foreground " \
                           "h-10 px-4 py-2"
                  ) { "More info" }
                  render ::Components::UI::PopoverContent.new do
                    p(class: "text-sm mb-3") { "This is a floating panel anchored to the trigger." }
                    render ::Components::UI::PopoverClose.new { "Close" }
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
                li { "role=\"dialog\" (Zag's popover default); aria-labelledby and aria-describedby wired through the title/description slots when present." }
                li { "Positioning handled by Zag's positioner — keeps the panel in view at viewport edges." }
                li { "Click-outside and Escape close the popover." }
                li { "Focus moves into the panel on open and returns to the trigger on close." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "popover", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
