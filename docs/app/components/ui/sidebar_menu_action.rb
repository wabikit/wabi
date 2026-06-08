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

      # aria_label: accessible name for this icon-only action button.
      # Callers should always provide a meaningful label (e.g. aria_label: "More options").
      def initialize(aria_label: nil, **attrs)
        @aria_label = aria_label
        @attrs      = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(type: "button", "aria-label": @aria_label, **@attrs, class: merge_class(tokens, user_class)) { yield if block }
      end
    end
  end
end
