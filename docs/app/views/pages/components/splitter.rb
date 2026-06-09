# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Splitter < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/splitter.rb
          app/components/ui/splitter_panel.rb
          app/components/ui/splitter_resize_trigger.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Splitter", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Splitter" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(source: "bin/rails g wabi:add splitter", language: "shell")

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                # Splitter fills its parent (Zag sets height:100%), so wrap it in a sized box.
                div(class: "h-48 overflow-hidden rounded-md border border-input") do
                  render Components::UI::Splitter.new(panels: [{ id: "a", minSize: 20 }, { id: "b", minSize: 20 }]) do
                    render Components::UI::SplitterPanel.new(id: "a", class: "grid place-items-center text-sm") { "Panel A" }
                    render Components::UI::SplitterResizeTrigger.new(id: "a:b")
                    render Components::UI::SplitterPanel.new(id: "b", class: "grid place-items-center text-sm") { "Panel B" }
                  end
                end
              RUBY
                div(class: "h-48 overflow-hidden rounded-md border border-input") do
                  render ::Components::UI::Splitter.new(panels: [{ id: "a", minSize: 20 }, { id: "b", minSize: 20 }]) do
                    render ::Components::UI::SplitterPanel.new(id: "a", class: "grid place-items-center text-sm") { "Panel A" }
                    render ::Components::UI::SplitterResizeTrigger.new(id: "a:b")
                    render ::Components::UI::SplitterPanel.new(id: "b", class: "grid place-items-center text-sm") { "Panel B" }
                  end
                end
              end

              h2(id: "vertical", class: "text-2xl font-semibold mt-8 mb-4") { "Vertical orientation" }
              p(class: "text-muted-foreground mb-4 text-sm") do
                plain "Pass "
                code(class: "font-mono text-foreground") { "orientation: :vertical" }
                plain " to stack panels top-to-bottom; the resize trigger then drags up/down."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                div(class: "h-64 overflow-hidden rounded-md border border-input") do
                  render Components::UI::Splitter.new(orientation: :vertical, panels: [{ id: "top", minSize: 20 }, { id: "bottom", minSize: 20 }]) do
                    render Components::UI::SplitterPanel.new(id: "top", class: "grid place-items-center text-sm") { "Top" }
                    render Components::UI::SplitterResizeTrigger.new(id: "top:bottom", aria_label: "Resize panels")
                    render Components::UI::SplitterPanel.new(id: "bottom", class: "grid place-items-center text-sm") { "Bottom" }
                  end
                end
              RUBY
                div(class: "h-64 overflow-hidden rounded-md border border-input") do
                  render ::Components::UI::Splitter.new(orientation: :vertical, panels: [{ id: "top", minSize: 20 }, { id: "bottom", minSize: 20 }]) do
                    render ::Components::UI::SplitterPanel.new(id: "top", class: "grid place-items-center text-sm") { "Top" }
                    render ::Components::UI::SplitterResizeTrigger.new(id: "top:bottom", aria_label: "Resize panels")
                    render ::Components::UI::SplitterPanel.new(id: "bottom", class: "grid place-items-center text-sm") { "Bottom" }
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
                li { "Each gutter is role=\"separator\" with aria-valuenow; arrow keys resize, Home/End jump to min/max." }
                li { "Set min/max sizes per panel via the panels: config." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "splitter", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
