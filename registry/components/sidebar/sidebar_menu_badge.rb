# frozen_string_literal: true

module Components
  module UI
    class SidebarMenuBadge < Wabi::Base
      variants do
        base "pointer-events-none absolute right-2 top-1/2 flex h-5 min-w-5 -translate-y-1/2 " \
             "select-none items-center justify-center rounded-md px-1 text-xs font-medium tabular-nums " \
             "text-sidebar-foreground " \
             "group-data-[state=collapsed]/sidebar:hidden"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&block)
        user_class = @attrs.delete(:class)
        span(**@attrs, class: merge_class(tokens, user_class)) { yield if block }
      end
    end
  end
end
