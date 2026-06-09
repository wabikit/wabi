# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Carousel < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/carousel.rb
          app/components/ui/carousel_item_group.rb
          app/components/ui/carousel_item.rb
          app/components/ui/carousel_control.rb
          app/components/ui/carousel_prev_trigger.rb
          app/components/ui/carousel_next_trigger.rb
          app/components/ui/carousel_indicator_group.rb
          app/components/ui/carousel_indicator.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Carousel", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Carousel" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(source: "bin/rails g wabi:add carousel", language: "shell")

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Carousel.new(slide_count: 3, loop: true) do
                  render Components::UI::CarouselItemGroup.new do
                    3.times do |i|
                      render Components::UI::CarouselItem.new(index: i, class: "grid h-40 place-items-center rounded-md bg-muted text-2xl font-semibold") { "Slide \#{i + 1}" }
                    end
                  end
                  render Components::UI::CarouselControl.new do
                    render Components::UI::CarouselPrevTrigger.new
                    render Components::UI::CarouselIndicatorGroup.new do
                      3.times { |i| render Components::UI::CarouselIndicator.new(index: i) }
                    end
                    render Components::UI::CarouselNextTrigger.new
                  end
                end
              RUBY
                render ::Components::UI::Carousel.new(slide_count: 3, loop: true) do
                  render ::Components::UI::CarouselItemGroup.new do
                    3.times do |i|
                      render ::Components::UI::CarouselItem.new(index: i, class: "grid h-40 place-items-center rounded-md bg-muted text-2xl font-semibold") { "Slide #{i + 1}" }
                    end
                  end
                  render ::Components::UI::CarouselControl.new do
                    render ::Components::UI::CarouselPrevTrigger.new
                    render ::Components::UI::CarouselIndicatorGroup.new do
                      3.times { |i| render ::Components::UI::CarouselIndicator.new(index: i) }
                    end
                    render ::Components::UI::CarouselNextTrigger.new
                  end
                end
              end

              h2(id: "autoplay", class: "text-2xl font-semibold mt-8 mb-4") { "Autoplay" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Carousel.new(slide_count: 3, loop: true, autoplay: true) do
                  render Components::UI::CarouselItemGroup.new do
                    3.times do |i|
                      render Components::UI::CarouselItem.new(index: i, class: "grid h-40 place-items-center rounded-md bg-muted text-2xl font-semibold") { "Slide \#{i + 1}" }
                    end
                  end
                  render Components::UI::CarouselControl.new do
                    render Components::UI::CarouselPrevTrigger.new
                    render Components::UI::CarouselIndicatorGroup.new do
                      3.times { |i| render Components::UI::CarouselIndicator.new(index: i) }
                    end
                    render Components::UI::CarouselNextTrigger.new
                  end
                end
              RUBY
                render ::Components::UI::Carousel.new(slide_count: 3, loop: true, autoplay: true) do
                  render ::Components::UI::CarouselItemGroup.new do
                    3.times do |i|
                      render ::Components::UI::CarouselItem.new(index: i, class: "grid h-40 place-items-center rounded-md bg-muted text-2xl font-semibold") { "Slide #{i + 1}" }
                    end
                  end
                  render ::Components::UI::CarouselControl.new do
                    render ::Components::UI::CarouselPrevTrigger.new
                    render ::Components::UI::CarouselIndicatorGroup.new do
                      3.times { |i| render ::Components::UI::CarouselIndicator.new(index: i) }
                    end
                    render ::Components::UI::CarouselNextTrigger.new
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
                li { "Root is aria-roledescription=\"carousel\"; each slide announces its position." }
                li { "Prev/Next/indicator buttons are keyboard-operable; autoplay pauses on focus/hover." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "carousel", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
