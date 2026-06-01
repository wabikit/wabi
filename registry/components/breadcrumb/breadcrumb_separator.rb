# frozen_string_literal: true

module Components
  module UI
    class BreadcrumbSeparator < Wabi::Base
      variants do
        base "[&>svg]:size-3.5"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&block)
        user_class = @attrs.delete(:class)
        li(role: "presentation", "aria-hidden": "true",
           **@attrs, class: merge_class(tokens, user_class)) do
          if block
            yield
          else
            raw(safe('<svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>'))
          end
        end
      end
    end
  end
end
