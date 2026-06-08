# frozen_string_literal: true

module Components
  module UI
    class BreadcrumbEllipsis < Wabi::Base
      variants do
        base "flex size-9 items-center justify-center"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template
        user_class = @attrs.delete(:class)
        span(role: "presentation",
             **@attrs, class: merge_class(tokens, user_class)) do
          raw(safe('<svg aria-hidden="true" focusable="false" class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="12" r="1.5"/><circle cx="19" cy="12" r="1.5"/><circle cx="5" cy="12" r="1.5"/></svg>'))
          span(class: "sr-only") { "More" }
        end
      end
    end
  end
end
