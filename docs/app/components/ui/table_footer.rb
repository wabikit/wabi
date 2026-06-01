# frozen_string_literal: true

module Components
  module UI
    class TableFooter < Wabi::Base
      variants do
        base "border-t bg-muted/50 font-medium [&>tr]:last:border-b-0"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        tfoot(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
