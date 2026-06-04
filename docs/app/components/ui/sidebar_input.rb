# frozen_string_literal: true

module Components
  module UI
    class SidebarInput < Wabi::Base
      variants do
        base "h-8 w-full rounded-md border border-sidebar-border bg-background px-2 text-sm shadow-none " \
             "outline-none placeholder:text-muted-foreground " \
             "focus-visible:ring-2 focus-visible:ring-sidebar-ring " \
             "group-data-[state=collapsed]/sidebar:hidden"
      end

      def initialize(type: "search", **attrs)
        @type  = type
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        input(type: @type, **@attrs, class: merge_class(tokens, user_class))
      end
    end
  end
end
