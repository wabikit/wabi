# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Toggle < Views::Base
        SOURCE_PATHS = %w[app/components/ui/toggle.rb].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Toggle", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Toggle" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add toggle\nbin/importmap pin @zag-js/toggle\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/toggle and @zag-js/vanilla at version 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only downloads the main entry and leaves submodule imports unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Toggle.new { "Bold" }
              RUBY
                render ::Components::UI::Toggle.new { "Bold" }
              end

              h2(id: "appearance", class: "text-2xl font-semibold mt-8 mb-4") { "Appearance" }
              p(class: "text-muted-foreground mb-4 text-sm") do
                plain "Pass "
                code(class: "font-mono text-foreground") { "appearance: :outline" }
                plain " for a bordered variant. The default is borderless."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                div(class: "flex items-center gap-2") do
                  render Components::UI::Toggle.new(appearance: :default) { "Default" }
                  render Components::UI::Toggle.new(appearance: :outline) { "Outline" }
                end
              RUBY
                div(class: "flex items-center gap-2") do
                  render ::Components::UI::Toggle.new(appearance: :default) { "Default" }
                  render ::Components::UI::Toggle.new(appearance: :outline) { "Outline" }
                end
              end

              h2(id: "sizes", class: "text-2xl font-semibold mt-8 mb-4") { "Sizes" }
              p(class: "text-muted-foreground mb-4 text-sm") do
                plain "Use "
                code(class: "font-mono text-foreground") { "size:" }
                plain " to pick "
                code(class: "font-mono text-foreground") { ":sm" }
                plain ", "
                code(class: "font-mono text-foreground") { ":default" }
                plain ", or "
                code(class: "font-mono text-foreground") { ":lg" }
                plain "."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                div(class: "flex items-center gap-2") do
                  render Components::UI::Toggle.new(appearance: :outline, size: :sm)      { "Small" }
                  render Components::UI::Toggle.new(appearance: :outline, size: :default) { "Default" }
                  render Components::UI::Toggle.new(appearance: :outline, size: :lg)      { "Large" }
                end
              RUBY
                div(class: "flex items-center gap-2") do
                  render ::Components::UI::Toggle.new(appearance: :outline, size: :sm)      { "Small" }
                  render ::Components::UI::Toggle.new(appearance: :outline, size: :default) { "Default" }
                  render ::Components::UI::Toggle.new(appearance: :outline, size: :lg)      { "Large" }
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
                li { 'role="button" with aria-pressed reflecting current state.' }
                li { "Space and Enter toggle the state." }
                li { "Use Switch instead for binary settings; Toggle is for press-style buttons in toolbars." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "toggle", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
