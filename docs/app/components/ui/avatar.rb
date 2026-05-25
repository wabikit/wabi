# frozen_string_literal: true

module Components
  module UI
    class Avatar < Wabi::Base
      variants { base "relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full" }

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        span(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
