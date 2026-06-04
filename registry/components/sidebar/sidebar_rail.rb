# frozen_string_literal: true

module Components
  module UI
    class SidebarRail < Wabi::Base
      BASE = "absolute inset-y-0 z-20 hidden w-4 lg:flex items-center justify-center outline-none group/rail " \
             "after:absolute after:inset-y-0 after:w-px after:bg-sidebar-border after:transition-colors " \
             "hover:after:bg-sidebar-ring focus-visible:after:bg-sidebar-ring"

      SIDE = {
        left:  "right-0 cursor-w-resize after:right-0",
        right: "left-0 cursor-e-resize after:left-0",
      }.freeze

      def initialize(side: :left, **attrs)
        @side  = side
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        user_data  = @attrs.delete(:data) || {}
        button(
          type: "button",
          "aria-label": "Toggle sidebar",
          tabindex: -1,
          **@attrs,
          data: { **user_data, action: "wabi--sidebar#toggle" },
          class: merge_class(BASE, SIDE.fetch(@side, SIDE[:left]), user_class)
        )
      end
    end
  end
end
