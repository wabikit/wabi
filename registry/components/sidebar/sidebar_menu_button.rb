# frozen_string_literal: true

module Components
  module UI
    class SidebarMenuButton < Wabi::Base
      variants do
        base "flex w-full items-center gap-2 overflow-hidden rounded-md px-2 py-1.5 text-left " \
             "text-sm text-foreground outline-none transition-colors " \
             "hover:bg-accent hover:text-accent-foreground " \
             "focus-visible:ring-2 focus-visible:ring-ring " \
             "disabled:pointer-events-none disabled:opacity-50 " \
             "aria-[current=page]:bg-accent aria-[current=page]:text-accent-foreground " \
             "aria-[current=page]:font-medium " \
             "group-data-[state=collapsed]/sidebar:justify-center " \
             "group-data-[state=collapsed]/sidebar:[&>span]:hidden"
      end

      def initialize(href: nil, active: false, tooltip: nil, **attrs)
        @href    = href
        @active  = active
        @tooltip = tooltip
        @attrs   = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        klass = merge_class(tokens, user_class)
        if @href
          a(href: @href, "aria-current": (@active ? "page" : nil), class: klass) { yield if block }
        else
          button(type: "button", "aria-current": (@active ? "page" : nil), class: klass) { yield if block }
        end
      end
    end
  end
end
