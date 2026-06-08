# frozen_string_literal: true

module Components
  module UI
    class PaginationEllipsis < Wabi::Base
      variants do
        base "flex h-9 w-9 items-center justify-center"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template
        user_class = @attrs.delete(:class)
        # aria-hidden lives on the decorative SVG only — NOT the wrapper, or it
        # would also hide the sr-only "More pages" text from assistive tech.
        span(**@attrs, class: merge_class(tokens, user_class)) do
          raw(safe('<svg aria-hidden="true" focusable="false" class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="12" r="1.5"/><circle cx="19" cy="12" r="1.5"/><circle cx="5" cy="12" r="1.5"/></svg>'))
          span(class: "sr-only") { "More pages" }
        end
      end
    end
  end
end
