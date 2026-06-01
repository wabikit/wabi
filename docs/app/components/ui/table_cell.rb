# frozen_string_literal: true

module Components
  module UI
    class TableCell < Wabi::Base
      variants do
        base "p-4 align-middle [&:has([role=checkbox])]:pr-0"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        td(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
