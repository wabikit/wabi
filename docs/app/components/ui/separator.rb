# frozen_string_literal: true

module Components
  module UI
    class Separator < Wabi::Base
      variants do
        base "shrink-0 bg-border"

        variant :orientation, {
          horizontal: "h-[1px] w-full",
          vertical:   "h-full w-[1px]"
        }, default: :horizontal
      end

      def initialize(orientation: nil, decorative: true, **attrs)
        @orientation = orientation
        @decorative  = decorative
        @attrs       = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        aria_orientation = @orientation == :vertical ? "vertical" : "horizontal"
        div(
          role: @decorative ? "none" : "separator",
          "aria-orientation": (@decorative ? nil : aria_orientation),
          **@attrs,
          class: merge_class(tokens(orientation: @orientation), user_class)
        )
      end
    end
  end
end
