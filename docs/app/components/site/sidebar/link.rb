# frozen_string_literal: true

module Components
  module Site
    class Sidebar
      class Link < Components::Base
        def initialize(name:, path:, current_path:)
          @name = name
          @path = path
          @active = (path == current_path)
        end

        def view_template
          li do
            a(href: @path,
              "aria-current": (@active ? "page" : nil),
              class: "block px-2 py-1 rounded-sm text-sm text-muted-foreground " \
                     "hover:text-foreground " \
                     "aria-current:bg-accent aria-current:text-foreground aria-current:font-medium") { @name }
          end
        end
      end
    end
  end
end
