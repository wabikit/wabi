# frozen_string_literal: true

module Components
  module UI
    class AvatarFallback < Wabi::Base
      variants { base "flex h-full w-full items-center justify-center rounded-full bg-muted" }

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        span(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
