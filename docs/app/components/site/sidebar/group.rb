# frozen_string_literal: true

module Components
  module Site
    class Sidebar
      class Group < Components::Base
        def initialize(label:, items:, current_path:)
          @label = label
          @items = items
          @current_path = current_path
        end

        def view_template
          div(class: "mb-6") do
            h3(class: "text-xs font-semibold uppercase tracking-wider text-muted-foreground px-2 mb-2") { raw safe(@label) }
            ul(class: "space-y-0.5") do
              @items.each do |item|
                render Components::Site::Sidebar::Link.new(
                  name: item[:name], path: item[:path], current_path: @current_path
                )
              end
            end
          end
        end
      end
    end
  end
end
