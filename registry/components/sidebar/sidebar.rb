# frozen_string_literal: true

module Components
  module UI
    class Sidebar < Wabi::Base
      BASE = "flex flex-col bg-sidebar text-sidebar-foreground overflow-hidden " \
             "fixed inset-y-0 z-50 w-64 transition-transform duration-200 ease-in-out " \
             "group-data-[mobile=open]/sidebar:translate-x-0 " \
             "lg:sticky lg:top-0 lg:z-auto lg:h-svh lg:translate-x-0 lg:transition-[width] " \
             "lg:w-64 group-data-[state=collapsed]/sidebar:lg:w-[3.25rem] " \
             "group-data-[variant=floating]/sidebar:m-2 " \
             "group-data-[variant=floating]/sidebar:h-[calc(100svh-1rem)] " \
             "group-data-[variant=floating]/sidebar:rounded-lg " \
             "group-data-[variant=floating]/sidebar:border " \
             "group-data-[variant=floating]/sidebar:border-sidebar-border " \
             "group-data-[variant=floating]/sidebar:shadow-lg " \
             "group-data-[variant=inset]/sidebar:border-0 " \
             "group-data-[variant=inset]/sidebar:bg-transparent"

      SIDE = {
        left:  "left-0 border-r border-sidebar-border -translate-x-full",
        right: "right-0 border-l border-sidebar-border translate-x-full",
      }.freeze

      def initialize(side: :left, **attrs)
        @side  = side
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        # Default accessible name: the panel is a complementary landmark on
        # desktop and becomes role="dialog" on mobile (set by the controller),
        # where it needs a name. Callers can override via aria-label:.
        aria_label = @attrs.delete(:"aria-label") || "Sidebar"
        aside(
          **@attrs,
          "aria-label": aria_label,
          data: { "wabi--sidebar-target": "panel" },
          tabindex: -1,
          class: merge_class(BASE, SIDE.fetch(@side, SIDE[:left]), user_class)
        ) do
          yield if block
        end
      end
    end
  end
end
