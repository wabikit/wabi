# frozen_string_literal: true

module Components
  module Site
    class TableOfContents < Components::Base
      def view_template
        aside(class: "hidden xl:block w-48 flex-shrink-0 h-[calc(100vh-3.5rem)] " \
                     "sticky top-14 overflow-y-auto py-6 px-4",
              data: { controller: "site--toc" }) do
          h3(class: "text-xs font-semibold uppercase tracking-wider text-muted-foreground mb-2") { "On this page" }
          ul(data: { "site--toc-target": "list" }, class: "space-y-1 text-sm")
        end
      end
    end
  end
end
