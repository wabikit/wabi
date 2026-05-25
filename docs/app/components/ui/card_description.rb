# frozen_string_literal: true

module Components
  module UI
    class CardDescription < Wabi::Base
      variants do
        base "text-sm text-muted-foreground"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        p(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
