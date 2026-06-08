# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class ColorPicker < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/color_picker.rb
          app/components/ui/color_picker_content.rb
          app/components/ui/color_picker_channel_slider.rb
        ].freeze

        PRESETS = %w[#ef4444 #f59e0b #10b981 #3b82f6 #8b5cf6].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Color Picker", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Color Picker" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add color_picker\nbin/importmap pin @zag-js/color-picker\nbin/importmap pin @zag-js/color-utils\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/color-picker, @zag-js/color-utils, and @zag-js/vanilla at version 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only downloads the main entry and leaves submodule imports unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::ColorPicker.new(value: "#3b82f6", name: "brand") do
                  render Components::UI::ColorPickerControl.new do
                    render Components::UI::ColorPickerTrigger.new do
                      render Components::UI::ColorPickerValueSwatch.new
                      render Components::UI::ColorPickerValueText.new
                    end
                  end
                  render Components::UI::ColorPickerContent.new do
                    render Components::UI::ColorPickerArea.new
                    render Components::UI::ColorPickerChannelSlider.new(channel: "hue")
                    render Components::UI::ColorPickerChannelSlider.new(channel: "alpha")
                    render Components::UI::ColorPickerChannelInput.new(channel: "hex")
                    render Components::UI::ColorPickerSwatchGroup.new do
                      %w[#ef4444 #f59e0b #10b981 #3b82f6 #8b5cf6].each do |hex|
                        render Components::UI::ColorPickerSwatch.new(value: hex)
                      end
                    end
                  end
                end
              RUBY
                render ::Components::UI::ColorPicker.new(value: "#3b82f6", name: "brand") do
                  render ::Components::UI::ColorPickerControl.new do
                    render ::Components::UI::ColorPickerTrigger.new do
                      render ::Components::UI::ColorPickerValueSwatch.new
                      render ::Components::UI::ColorPickerValueText.new
                    end
                  end
                  render ::Components::UI::ColorPickerContent.new do
                    render ::Components::UI::ColorPickerArea.new
                    render ::Components::UI::ColorPickerChannelSlider.new(channel: "hue")
                    render ::Components::UI::ColorPickerChannelSlider.new(channel: "alpha")
                    render ::Components::UI::ColorPickerChannelInput.new(channel: "hex")
                    render ::Components::UI::ColorPickerSwatchGroup.new do
                      PRESETS.each do |hex|
                        render ::Components::UI::ColorPickerSwatch.new(value: hex)
                      end
                    end
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
                li { "Area and channel sliders are keyboard-operable (arrow keys); the trigger exposes aria-expanded." }
                li { "Set name: to submit the color as a hidden form field." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "color_picker", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
