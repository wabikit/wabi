# frozen_string_literal: true

module Views
  module Pages
    module Docs
      class GettingStarted < Views::Base
        def view_template
          render ::Components::Site::Layout.new(title: "Getting Started") do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              h1(class: "text-4xl font-bold mb-4") { "Getting started" }
              p(class: "text-muted-foreground mb-8") do
                "Add Wabi to a Rails 8 app in four steps."
              end

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "1. Install the gem" }
              render ::Components::Site::CodeBlock.new(language: "shell", source: "bundle add wabi")

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "2. Run the installer" }
              render ::Components::Site::CodeBlock.new(language: "shell", source: "bin/rails g wabi:install")
              p(class: "text-sm text-muted-foreground mt-2") do
                "Copies the default tokens.css, the theme controller, and initializes config/wabi.lock.json."
              end

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "3. Wire Tailwind 4" }
              p(class: "text-sm mb-2") do
                plain "In "
                code(class: "px-1 py-0.5 rounded bg-muted text-sm") { "app/assets/tailwind/application.css" }
                plain ", import the tokens AFTER tailwindcss:"
              end
              render ::Components::Site::CodeBlock.new(language: "css", source: <<~CSS)
                @import "tailwindcss";
                @import "./wabi/tokens.css";
              CSS
              p(class: "text-sm text-muted-foreground mt-2") do
                plain "Use "
                code(class: "px-1 py-0.5 rounded bg-muted text-sm") { "stylesheet_link_tag \"tailwind\"" }
                plain ' (not "application") so the compiled output is what loads.'
              end

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "4. Mount the theme controller" }
              p(class: "text-sm mb-2") do
                plain "On your "
                code(class: "px-1 py-0.5 rounded bg-muted text-sm") { "<html>" }
                plain " tag so Wabi can read/write data-theme and data-mode for theme + dark-mode switching:"
              end
              render ::Components::Site::CodeBlock.new(language: "ruby", source: <<~RUBY)
                html(data: { controller: "wabi--theme" }) do
                  # ...
                end
              RUBY

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "5. Add components" }
              render ::Components::Site::CodeBlock.new(language: "shell", source: "bin/rails g wabi:add button dialog card")
              p(class: "text-sm text-muted-foreground mt-2") do
                plain "Components autoload under "
                code(class: "px-1 py-0.5 rounded bg-muted text-sm") { "Components::UI::*" }
                plain " (Phlex 2.x convention). Render them anywhere:"
              end
              render ::Components::Site::CodeBlock.new(language: "ruby", source: <<~RUBY)
                render Components::UI::Button.new(appearance: :primary) { "Click me" }
              RUBY

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "What's next" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li do
                  a(href: "/docs/components", class: "underline hover:text-foreground") { "Browse the components" }
                end
                li do
                  a(href: "/docs/theming", class: "underline hover:text-foreground") { "Pick a theme" }
                  plain " or "
                  a(href: "/docs/themes", class: "underline hover:text-foreground") { "view the gallery" }
                end
                li do
                  a(href: "/docs/philosophy", class: "underline hover:text-foreground") { "Why \"you own the code\"" }
                end
              end
            end
          end
        end
      end
    end
  end
end
