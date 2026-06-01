# frozen_string_literal: true

module Components
  module UI
    class BreadcrumbList < Wabi::Base
      variants do
        base "flex flex-wrap items-center gap-1.5 break-words text-sm text-muted-foreground sm:gap-2.5"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        ol(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
