# frozen_string_literal: true

module Components
  module UI
    class TableHead < Wabi::Base
      variants do
        base "h-12 px-4 text-left align-middle font-medium text-muted-foreground [&:has([role=checkbox])]:pr-0"
      end

      # +scope+ defaults to "col" so screen readers can associate header cells
      # with data cells. Override with scope: "row" for row-header <th> cells.
      def initialize(scope: "col", **attrs)
        @attrs = attrs.merge(scope: scope)
      end

      def view_template(&)
        user_class = @attrs.delete(:class)
        th(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
