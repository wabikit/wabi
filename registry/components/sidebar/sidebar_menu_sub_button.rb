# frozen_string_literal: true

module Components
  module UI
    class SidebarMenuSubButton < Wabi::Base
      variants do
        base "flex h-7 w-full min-w-0 items-center gap-2 overflow-hidden rounded-md px-2 text-sm " \
             "text-sidebar-foreground outline-none transition-colors " \
             "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground " \
             "focus-visible:ring-2 focus-visible:ring-sidebar-ring " \
             "aria-[current=page]:bg-sidebar-accent aria-[current=page]:text-sidebar-accent-foreground " \
             "aria-[current=page]:font-medium"
      end

      def initialize(href: nil, active: false, **attrs)
        @href   = href
        @active = active
        @attrs  = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        klass = merge_class(tokens, user_class)
        if @href
          a(href: @href, **@attrs, "aria-current": (@active ? "page" : nil), class: klass) { yield if block }
        else
          button(type: "button", **@attrs, "aria-current": (@active ? "page" : nil), class: klass) { yield if block }
        end
      end
    end
  end
end
