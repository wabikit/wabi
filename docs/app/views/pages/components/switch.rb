# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Switch < Views::Base
        SOURCE_PATHS = %w[app/components/ui/switch.rb].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Switch", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Switch" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add switch\nbin/importmap pin @zag-js/switch\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/switch and @zag-js/vanilla at version 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only downloads the main entry and leaves submodule imports unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                div(class: "flex items-center gap-6") do
                  render Components::UI::Switch.new(name: "notif") { "Notifications" }
                  render Components::UI::Switch.new(name: "sub", checked: true, aria_label: "Subscribe")
                  render Components::UI::Switch.new(name: "off", disabled: true, aria_label: "Disabled option")
                end
              RUBY
                div(class: "flex items-center gap-6") do
                  render ::Components::UI::Switch.new(name: "notif") { "Notifications" }
                  render ::Components::UI::Switch.new(name: "sub", checked: true, aria_label: "Subscribe")
                  render ::Components::UI::Switch.new(name: "off", disabled: true, aria_label: "Disabled option")
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
                li { 'role="switch" with aria-checked reflecting state.' }
                li { "Space toggles state; Tab moves to next focusable." }
                li { "focus-visible:ring is visible without click pollution." }
                li { "disabled state via aria-disabled + visual opacity reduction." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "switch", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
