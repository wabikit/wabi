# frozen_string_literal: true

module Components
  module UI
    class TableBody < Wabi::Base
      variants do
        base "[&_tr:last-child]:border-0"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        tbody(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
