# frozen_string_literal: true

module Components
  module UI
    class Card < Wabi::Base
      variants do
        base "rounded-lg border bg-card text-card-foreground shadow-sm"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        div(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
