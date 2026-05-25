# frozen_string_literal: true

module Components
  module UI
    class CardContent < Wabi::Base
      variants do
        base "p-6 pt-0"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        div(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
