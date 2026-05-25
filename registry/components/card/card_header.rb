# frozen_string_literal: true

module Components
  module UI
    class CardHeader < Wabi::Base
      variants do
        base "flex flex-col space-y-1.5 p-6"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        div(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
