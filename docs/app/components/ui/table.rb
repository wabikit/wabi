# frozen_string_literal: true

module Components
  module UI
    class Table < Wabi::Base
      variants do
        base "w-full caption-bottom text-sm"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        div(class: "relative w-full overflow-auto") do
          table(**@attrs, class: merge_class(tokens, user_class), &)
        end
      end
    end
  end
end
