# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Alert < Views::Base
        SOURCE_PATHS = %w[app/components/ui/alert.rb app/components/ui/alert_title.rb app/components/ui/alert_description.rb].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Alert", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Alert" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add alert",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Alert.new do
                  render Components::UI::AlertTitle.new { "Heads up!" }
                  render Components::UI::AlertDescription.new { "You can add components to your app using the wabi:add generator." }
                end
              RUBY
                render ::Components::UI::Alert.new do
                  render ::Components::UI::AlertTitle.new { "Heads up!" }
                  render ::Components::UI::AlertDescription.new { "You can add components to your app using the wabi:add generator." }
                end
              end

              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Alert.new(appearance: :destructive) do
                  render Components::UI::AlertTitle.new { "Error" }
                  render Components::UI::AlertDescription.new { "Your session has expired. Please log in again." }
                end
              RUBY
                render ::Components::UI::Alert.new(appearance: :destructive) do
                  render ::Components::UI::AlertTitle.new { "Error" }
                  render ::Components::UI::AlertDescription.new { "Your session has expired. Please log in again." }
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
                li { 'role="alert" — the panel is announced by assistive tech immediately on render.' }
                li { "live-region semantics: dynamic insertions trigger immediate announcement." }
                li { 'the "destructive" appearance is purely visual — it does NOT change the role or semantics.' }
                li { 'for non-urgent status, prefer role="status" or visually distinct UI without role="alert" to avoid screen-reader interruption.' }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "alert", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
