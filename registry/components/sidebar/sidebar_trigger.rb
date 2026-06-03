# frozen_string_literal: true

module Components
  module UI
    class SidebarTrigger < Wabi::Base
      variants do
        base "inline-flex h-9 w-9 items-center justify-center rounded-md text-foreground " \
             "transition-colors hover:bg-accent hover:text-accent-foreground " \
             "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          type: "button",
          "aria-label": "Toggle sidebar",
          data: { action: "wabi--sidebar#toggle" },
          class: merge_class(tokens, user_class)
        ) do
          if block
            yield
          else
            raw(safe(<<~SVG))
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect width="18" height="18" x="3" y="3" rx="2"/><path d="M9 3v18"/></svg>
            SVG
          end
        end
      end
    end
  end
end
