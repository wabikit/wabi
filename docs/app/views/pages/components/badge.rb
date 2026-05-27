# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Badge < Views::Base
        SOURCE_PATHS = %w[app/components/ui/badge.rb].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Badge", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Badge" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add badge",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                div(class: "flex items-center gap-2") do
                  render Components::UI::Badge.new { "Primary" }
                  render Components::UI::Badge.new(appearance: :secondary) { "Secondary" }
                  render Components::UI::Badge.new(appearance: :destructive) { "Destructive" }
                  render Components::UI::Badge.new(appearance: :outline) { "Outline" }
                end
              RUBY
                div(class: "flex items-center gap-2") do
                  render ::Components::UI::Badge.new { "Primary" }
                  render ::Components::UI::Badge.new(appearance: :secondary) { "Secondary" }
                  render ::Components::UI::Badge.new(appearance: :destructive) { "Destructive" }
                  render ::Components::UI::Badge.new(appearance: :outline) { "Outline" }
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
                li { "badges are visual decorations by default — screen readers announce their text content as inline text." }
                li { 'for status indicators (e.g. "3 unread"), wrap in <span role="status"> or add screen-reader-only context.' }
                li { "color alone is not sufficient signal — pair the visual badge with text or icon meaning." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "badge", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
