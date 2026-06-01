# frozen_string_literal: true

module Components
  module UI
    class Pagination < Wabi::Base
      variants do
        base "mx-auto flex w-full justify-center"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        nav(role: "navigation", "aria-label": "pagination",
            **@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
