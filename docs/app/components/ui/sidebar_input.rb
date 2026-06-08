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

      # aria_label: accessible name for the input (required by WCAG 1.3.1/2.4.6 when no visible
      # <label> is present). Defaults to "Search" matching the default type: "search".
      # Pass aria_label: nil if the input is already labelled by an associated <label> element.
      def initialize(type: "search", aria_label: "Search", **attrs)
        @type       = type
        @aria_label = aria_label
        @attrs      = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        input(type: @type, "aria-label": @aria_label, **@attrs, class: merge_class(tokens, user_class))
      end
    end
  end
end
