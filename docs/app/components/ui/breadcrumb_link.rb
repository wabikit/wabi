# frozen_string_literal: true

module Components
  module UI
    class BreadcrumbLink < Wabi::Base
      variants do
        base "transition-colors motion-reduce:transition-none hover:text-foreground"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        a(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
