# frozen_string_literal: true

module Components
  module UI
    class BreadcrumbItem < Wabi::Base
      variants do
        base "inline-flex items-center gap-1.5"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        li(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
