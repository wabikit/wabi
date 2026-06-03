# frozen_string_literal: true

module Components
  module UI
    class SidebarMenuAction < Wabi::Base
      variants do
        base "absolute right-1 top-1.5 flex h-6 w-6 items-center justify-center rounded-md " \
             "text-sidebar-foreground outline-none transition-opacity opacity-0 " \
             "group-hover/menu-item:opacity-100 focus-visible:opacity-100 " \
             "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground " \
             "focus-visible:ring-2 focus-visible:ring-sidebar-ring " \
             "group-data-[state=collapsed]/sidebar:hidden"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(type: "button", **@attrs, class: merge_class(tokens, user_class)) { yield if block }
      end
    end
  end
end
