# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Slider < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/slider.rb
          app/components/ui/slider_label.rb
          app/components/ui/slider_track.rb
          app/components/ui/slider_range.rb
          app/components/ui/slider_thumb.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Slider", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Slider" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add slider\nbin/importmap pin @zag-js/slider\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/slider and @zag-js/vanilla at version 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only downloads the main entry and leaves submodule imports unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Slider.new(name: "volume", value: 50, min: 0, max: 100) do
                  render Components::UI::SliderLabel.new { "Volume" }
                  render Components::UI::SliderTrack.new do
                    render Components::UI::SliderRange.new
                  end
                  render Components::UI::SliderThumb.new(index: 0)
                end

                # Range
                render Components::UI::Slider.new(name: "price", value: [20, 80]) do
                  render Components::UI::SliderLabel.new { "Price Range" }
                  render Components::UI::SliderTrack.new do
                    render Components::UI::SliderRange.new
                  end
                  render Components::UI::SliderThumb.new(index: 0)
                  render Components::UI::SliderThumb.new(index: 1)
                end
              RUBY
                render ::Components::UI::Slider.new(name: "volume", value: 50, min: 0, max: 100) do
                  render ::Components::UI::SliderLabel.new { "Volume" }
                  render ::Components::UI::SliderTrack.new do
                    render ::Components::UI::SliderRange.new
                  end
                  render ::Components::UI::SliderThumb.new(index: 0)
                end

                div(class: "h-8")

                render ::Components::UI::Slider.new(name: "price", value: [20, 80]) do
                  render ::Components::UI::SliderLabel.new { "Price Range" }
                  render ::Components::UI::SliderTrack.new do
                    render ::Components::UI::SliderRange.new
                  end
                  render ::Components::UI::SliderThumb.new(index: 0)
                  render ::Components::UI::SliderThumb.new(index: 1)
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
                li { 'role="slider" per thumb with aria-valuemin / aria-valuemax / aria-valuenow.' }
                li { "Arrow keys (←/→/↑/↓) adjust the focused thumb by one step." }
                li { "Home / End jump the focused thumb to the min / max." }
                li { "PageUp / PageDown move the focused thumb by a larger step (Zag default = 10× step)." }
                li { "Single-thumb sliders submit as `name=<value>`. Range sliders submit as `name[min]=...&name[max]=...`, which Rails parses to nested params (e.g. params[:price][:min])." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "slider", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
