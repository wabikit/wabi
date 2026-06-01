# frozen_string_literal: true

module Components
  module UI
    class PaginationContent < Wabi::Base
      variants do
        base "flex flex-row items-center gap-1"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        ul(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
