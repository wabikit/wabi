# frozen_string_literal: true

module Components
  module UI
    class CardTitle < Wabi::Base
      variants do
        base "text-2xl font-semibold leading-none tracking-tight"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        h3(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
