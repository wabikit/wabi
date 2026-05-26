# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Index < Views::Base
        # Reads the manifest description for every component at request time
        # so the index stays in sync with the registry without a build step.
        # Cached at class level: manifests change rarely, and dev reload
        # picks it up on file change anyway.
        @descriptions = nil

        class << self
          def descriptions
            @descriptions ||= ComponentsController::ALL.to_h do |name|
              manifest_path = Rails.root.join("..", "registry", "components", name, "manifest.yml").realpath
              data = YAML.safe_load_file(manifest_path)
              [name, data["description"].to_s]
            end
          end
        end

        def view_template
          render ::Components::Site::Layout.new(title: "Components") do
            main(class: "container mx-auto py-12 px-4 max-w-5xl") do
              h1(class: "text-4xl font-bold mb-2") { "Components" }
              p(class: "text-muted-foreground mb-8") do
                "All 20 v0.2 components. Click into the four exemplars for live previews + source; " \
                "the rest show description + a link to source on GitHub. Detailed pages for the " \
                "remaining 16 land in v0.4."
              end

              div(class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
                ::ComponentsController::ALL.each do |name|
                  detailed = ::ComponentsController::DETAILED.include?(name)
                  href     = detailed ? "/docs/components/#{name}" : nil
                  card_inner = lambda do
                    div(class: "rounded-lg border border-border p-5 h-full " \
                               "#{detailed ? 'hover:border-foreground transition-colors' : 'opacity-90'}") do
                      div(class: "flex items-baseline justify-between mb-2") do
                        h3(class: "text-lg font-semibold text-foreground") { name.titleize }
                        if detailed
                          span(class: "text-xs text-muted-foreground") { "Detailed →" }
                        else
                          span(class: "text-xs text-muted-foreground italic") { "Source only" }
                        end
                      end
                      p(class: "text-sm text-muted-foreground") do
                        self.class.descriptions.fetch(name, "")
                      end
                    end
                  end

                  if href
                    a(href: href, class: "block") { card_inner.call }
                  else
                    card_inner.call
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
