# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class HoverCard < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/hover_card.rb
          app/components/ui/hover_card_trigger.rb
          app/components/ui/hover_card_content.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Hover Card", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Hover Card" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add hover_card", language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::HoverCard.new do
                  render Components::UI::HoverCardTrigger.new { "@wabi" }
                  render Components::UI::HoverCardContent.new do
                    plain "The Rails component library you copy into your app."
                  end
                end
              RUBY
                render ::Components::UI::HoverCard.new do
                  render ::Components::UI::HoverCardTrigger.new { "@wabi" }
                  render ::Components::UI::HoverCardContent.new do
                    plain "The Rails component library you copy into your app."
                  end
                end
              end

              h2(id: "custom-delays", class: "text-2xl font-semibold mt-8 mb-4") { "Custom delays" }
              p(class: "text-sm text-muted-foreground mb-4") do
                "Tune open_delay: and close_delay: (milliseconds) to make the card appear " \
                "or dismiss faster. Defaults are 700 / 300."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::HoverCard.new(open_delay: 100, close_delay: 100) do
                  render Components::UI::HoverCardTrigger.new { "@wabi (snappy)" }
                  render Components::UI::HoverCardContent.new do
                    plain "Opens and closes almost instantly."
                  end
                end
              RUBY
                render ::Components::UI::HoverCard.new(open_delay: 100, close_delay: 100) do
                  render ::Components::UI::HoverCardTrigger.new { "@wabi (snappy)" }
                  render ::Components::UI::HoverCardContent.new do
                    plain "Opens and closes almost instantly."
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
                li { "Opens on pointer hover and on keyboard focus of the trigger." }
                li { "Content is inert and aria-hidden while closed; not a focus trap (non-modal)." }
                li { "Respects prefers-reduced-motion (fade transition is disabled)." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "hover_card", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
