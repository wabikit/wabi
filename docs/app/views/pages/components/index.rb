# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Index < Views::Base
        @descriptions = nil

        class << self
          def descriptions
            @descriptions ||= ComponentsController::ALL.to_h do |name|
              manifest_path = Rails.root.join("..", "registry", "components", name, "manifest.yml").realpath
              [name, YAML.safe_load_file(manifest_path)["description"].to_s]
            end
          end
        end

        def view_template
          render ::Components::Site::Layout.new(title: "Components", chrome: :sidebar_only) do
            main(class: "container mx-auto py-12 px-4 max-w-5xl") do
              h1(class: "text-4xl font-bold mb-2") { "Components" }
              p(class: "text-muted-foreground mb-8") do
                "All 20 components. Click any card for live previews + source + accessibility notes."
              end

              div(class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
                ::ComponentsController::ALL.each do |name|
                  a(href: "/docs/components/#{name}", class: "block") do
                    div(class: "rounded-lg border border-border p-5 h-full hover:border-foreground transition-colors") do
                      div(class: "flex items-baseline justify-between mb-2") do
                        h3(class: "text-lg font-semibold text-foreground") { name.titleize }
                        span(class: "text-xs text-muted-foreground") { "Detailed →" }
                      end
                      p(class: "text-sm text-muted-foreground") { self.class.descriptions.fetch(name, "") }
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
