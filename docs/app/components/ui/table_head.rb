# frozen_string_literal: true

module Components
  module UI
    class TableHead < Wabi::Base
      variants do
        base "h-12 px-4 text-left align-middle font-medium text-muted-foreground [&:has([role=checkbox])]:pr-0"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        th(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
