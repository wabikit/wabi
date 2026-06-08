# frozen_string_literal: true

module Components
  module UI
    class Skeleton < Wabi::Base
      variants do
        base "animate-pulse motion-reduce:animate-none rounded-md bg-muted"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        div(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
