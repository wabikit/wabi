# frozen_string_literal: true

module Components
  module UI
    class Label < Wabi::Base
      variants do
        base "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      end

      def initialize(for_: nil, **attrs)
        @for_  = for_
        @attrs = attrs
      end

      def view_template(&)
        user_class = @attrs.delete(:class)
        label(for: @for_, **@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
