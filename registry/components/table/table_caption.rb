# frozen_string_literal: true

module Components
  module UI
    class TableCaption < Wabi::Base
      variants do
        base "mt-4 text-sm text-muted-foreground"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        caption(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
