# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class RadioGroup < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/radio_group.rb
          app/components/ui/radio_group_item.rb
          app/components/ui/radio_group_indicator.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "RadioGroup", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "RadioGroup" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add radio_group\nbin/importmap pin @zag-js/radio-group\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/radio-group and @zag-js/vanilla at version 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only downloads the main entry and leaves submodule imports unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::RadioGroup.new(name: "plan", value: "pro") do
                  render Components::UI::RadioGroupItem.new(value: "free")       { "Free" }
                  render Components::UI::RadioGroupItem.new(value: "pro")        { "Pro" }
                  render Components::UI::RadioGroupItem.new(value: "enterprise") { "Enterprise" }
                end
              RUBY
                render ::Components::UI::RadioGroup.new(name: "plan", value: "pro") do
                  render ::Components::UI::RadioGroupItem.new(value: "free")       { "Free" }
                  render ::Components::UI::RadioGroupItem.new(value: "pro")        { "Pro" }
                  render ::Components::UI::RadioGroupItem.new(value: "enterprise") { "Enterprise" }
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
                li { 'role="radiogroup" wrapper + role="radio" per item.' }
                li { "Arrow keys move focus + selection. Space selects the focused item." }
                li { "When inside a <label>, clicking the label toggles the radio." }
                li { "Hidden <input type=\"radio\"> per item for form submission." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "radio_group", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
