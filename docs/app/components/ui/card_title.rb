# frozen_string_literal: true

module Components
  module UI
    class CardTitle < Wabi::Base
      variants do
        base "text-2xl font-semibold leading-none tracking-tight"
      end

      # level: (Integer, default 3) — heading level 1-6; allows callers to
      # match the document outline when the card is a top-level content block.
      def initialize(level: 3, **attrs)
        @level = level.to_i.clamp(1, 6)
        @attrs = attrs
      end

      def view_template(&)
        user_class = @attrs.delete(:class)
        send(:"h#{@level}", **@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
