# frozen_string_literal: true

module Components
  module UI
    class SidebarMenuSkeleton < Wabi::Base
      variants { base "flex h-8 items-center gap-2 rounded-md px-2" }

      def initialize(show_icon: true, **attrs)
        @show_icon = show_icon
        @attrs     = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        div(**@attrs, class: merge_class(tokens, user_class)) do
          div(class: "size-4 shrink-0 animate-pulse rounded-md bg-sidebar-accent") if @show_icon
          div(class: "bar h-4 max-w-[70%] flex-1 animate-pulse rounded-md bg-sidebar-accent " \
                     "group-data-[state=collapsed]/sidebar:hidden")
        end
      end
    end
  end
end
