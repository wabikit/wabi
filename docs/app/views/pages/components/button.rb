# frozen_string_literal: true

module Views
  module Pages
    module Components
      class Button < Views::Base
        SOURCE_PATH = Rails.root.join("app/components/ui/button.rb")

        def view_template
          render ::Components::Site::Layout.new(title: "Button", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Button" }
              p(class: "text-muted-foreground mb-8") do
                "A clickable button with appearance and size variants."
              end

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add button",
                language: "shell"
              )

              h2(id: "appearances", class: "text-2xl font-semibold mt-8 mb-4") { "Appearances" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Button.new                          { "Primary" }
                render Components::UI::Button.new(appearance: :secondary)   { "Secondary" }
                render Components::UI::Button.new(appearance: :destructive) { "Destructive" }
                render Components::UI::Button.new(appearance: :outline)     { "Outline" }
                render Components::UI::Button.new(appearance: :ghost)       { "Ghost" }
                render Components::UI::Button.new(appearance: :link)        { "Link" }
              RUBY
                div(class: "flex flex-wrap gap-2") do
                  render ::Components::UI::Button.new                          { "Primary" }
                  render ::Components::UI::Button.new(appearance: :secondary)   { "Secondary" }
                  render ::Components::UI::Button.new(appearance: :destructive) { "Destructive" }
                  render ::Components::UI::Button.new(appearance: :outline)     { "Outline" }
                  render ::Components::UI::Button.new(appearance: :ghost)       { "Ghost" }
                  render ::Components::UI::Button.new(appearance: :link)        { "Link" }
                end
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              render ::Components::Site::CodeBlock.new(source: File.read(SOURCE_PATH))

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "Native <button> element — keyboard accessible by default." }
                li { "focus-visible:ring-2 ring keeps focus state visible without polluting click affordance." }
                li { "Disabled state honored via disabled:pointer-events-none + opacity-50." }
              end
            end
          end
        end
      end
    end
  end
end
