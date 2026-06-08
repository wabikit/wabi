# frozen_string_literal: true

module Components
  module UI
    class TableRow < Wabi::Base
      variants do
        base "border-b transition-colors motion-reduce:transition-none hover:bg-muted/50 data-[state=selected]:bg-muted"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        tr(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
