# frozen_string_literal: true

module Components
  module UI
    class TableHeader < Wabi::Base
      variants do
        base "[&_tr]:border-b"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        thead(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
