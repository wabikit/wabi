# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Card < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/card.rb
          app/components/ui/card_header.rb
          app/components/ui/card_title.rb
          app/components/ui/card_description.rb
          app/components/ui/card_content.rb
          app/components/ui/card_footer.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Card", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Card" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add card",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Card.new(class: "max-w-sm") do
                  render Components::UI::CardHeader.new do
                    render Components::UI::CardTitle.new { "Notifications" }
                    render Components::UI::CardDescription.new { "You have 3 unread messages." }
                  end
                  render Components::UI::CardContent.new do
                    p { "Manage how and when you receive notifications." }
                  end
                  render Components::UI::CardFooter.new do
                    render Components::UI::Button.new { "Mark all as read" }
                  end
                end
              RUBY
                render ::Components::UI::Card.new(class: "max-w-sm") do
                  render ::Components::UI::CardHeader.new do
                    render ::Components::UI::CardTitle.new { "Notifications" }
                    render ::Components::UI::CardDescription.new { "You have 3 unread messages." }
                  end
                  render ::Components::UI::CardContent.new do
                    p { "Manage how and when you receive notifications." }
                  end
                  render ::Components::UI::CardFooter.new do
                    render ::Components::UI::Button.new { "Mark all as read" }
                  end
                end
              end

              h2(id: "example-standalone", class: "text-2xl font-semibold mt-8 mb-4") { "Standalone (no header)" }
              p(class: "text-muted-foreground mb-4 text-sm") do
                plain "For cards without a "
                code(class: "font-mono text-foreground") { "CardHeader" }
                plain ", pass "
                code(class: "font-mono text-foreground") { "padding: :standalone" }
                plain " to CardContent for symmetric vertical padding."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Card.new(class: "max-w-sm") do
                  render Components::UI::CardContent.new(
                    padding: :standalone,
                    class: "flex items-center justify-between gap-3"
                  ) do
                    div do
                      p(class: "font-medium") { "Storage" }
                      p(class: "text-sm text-muted-foreground") { "8.2 GB of 15 GB used" }
                    end
                    render Components::UI::Button.new(appearance: :outline, size: :sm) { "Upgrade" }
                  end
                end
              RUBY
                render ::Components::UI::Card.new(class: "max-w-sm") do
                  render ::Components::UI::CardContent.new(
                    padding: :standalone,
                    class: "flex items-center justify-between gap-3"
                  ) do
                    div do
                      p(class: "font-medium") { "Storage" }
                      p(class: "text-sm text-muted-foreground") { "8.2 GB of 15 GB used" }
                    end
                    render ::Components::UI::Button.new(appearance: :outline, size: :sm) { "Upgrade" }
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
                li { "Card is a structural container with no implicit semantics; the meaning comes from contents." }
                li { "CardTitle renders as h3 by default — verify the heading level fits the page outline." }
                li { "footer actions should be real <button> or <a> elements (the Button component is correct here), not styled <div>s." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "card", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
