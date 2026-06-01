# frozen_string_literal: true

module Components
  module UI
    class BreadcrumbPage < Wabi::Base
      variants do
        base "font-normal text-foreground"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        span(role: "link", "aria-disabled": "true", "aria-current": "page",
             **@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
