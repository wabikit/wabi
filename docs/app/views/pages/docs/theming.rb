# frozen_string_literal: true

module Views
  module Pages
    module Docs
      class Theming < Views::Base
        def view_template
          render ::Components::Site::Layout.new(title: "Theming", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              h1(class: "text-4xl font-bold mb-4") { "Theming" }
              p(class: "text-muted-foreground mb-8") do
                plain "Wabi ships 8 pre-built palettes. The "
                a(href: "/docs/themes", class: "underline hover:text-foreground") { "gallery" }
                plain " shows them side-by-side; this page covers how to switch and customize."
              end

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "Switching themes in your app" }
              render ::Components::Site::CodeBlock.new(language: "shell", source: "bin/rails g wabi:theme rose")
              p(class: "text-sm text-muted-foreground mt-2") do
                plain "Overwrites "
                code(class: "px-1 py-0.5 rounded bg-muted text-sm") { "app/assets/tailwind/wabi/tokens.css" }
                plain " with the rose palette. Re-run "
                code(class: "px-1 py-0.5 rounded bg-muted text-sm") { "bin/rails tailwindcss:build" }
                plain " to recompile."
              end

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "Available palettes" }
              ul(class: "grid grid-cols-2 sm:grid-cols-4 gap-2 text-sm") do
                %w[default slate stone zinc rose blue green violet].each do |slug|
                  li(class: "rounded border border-border px-3 py-1.5 text-center") { slug.capitalize }
                end
              end

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "Dark mode" }
              p(class: "text-sm mb-2") do
                plain "Every palette has a dark variant. The "
                code(class: "px-1 py-0.5 rounded bg-muted text-sm") { "wabi--theme" }
                plain " Stimulus controller toggles "
                code(class: "px-1 py-0.5 rounded bg-muted text-sm") { "data-mode" }
                plain ' on <html> and persists it in localStorage. To toggle in JS:'
              end
              render ::Components::Site::CodeBlock.new(language: "ruby", source: <<~RUBY)
                button(
                  type: "button",
                  data: { action: "click->wabi--theme#toggleMode" }
                ) { "Toggle dark mode" }
              RUBY

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "Customizing a palette" }
              p(class: "text-sm mb-2") do
                plain "Tokens are CSS variables in HSL space. Edit "
                code(class: "px-1 py-0.5 rounded bg-muted text-sm") { "app/assets/tailwind/wabi/tokens.css" }
                plain " directly — components reference these variables, so any change propagates:"
              end
              render ::Components::Site::CodeBlock.new(language: "css", source: <<~CSS)
                :root, [data-theme="default"] {
                  --primary: 220 90% 56%;     /* your brand blue */
                  --primary-foreground: 0 0% 100%;
                  /* ... */
                }
              CSS

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "Notes on Tailwind 4" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li do
                  plain "Wabi uses TW4 native "
                  code(class: "px-1 py-0.5 rounded bg-muted text-sm") { "@theme inline" }
                  plain " — no preset.js, no tailwind.config.js needed."
                end
                li do
                  plain "The "
                  code(class: "px-1 py-0.5 rounded bg-muted text-sm") { "dark:" }
                  plain " variant is wired via "
                  code(class: "px-1 py-0.5 rounded bg-muted text-sm") { "@custom-variant" }
                  plain ' — fires when an ancestor has data-mode="dark", regardless of theme.'
                end
                li do
                  plain "If Tailwind doesn't pick up your component classes, add "
                  code(class: "px-1 py-0.5 rounded bg-muted text-sm") { '@source "../../components/**/*.rb";' }
                  plain " near the top of application.css."
                end
              end
            end
          end
        end
      end
    end
  end
end
