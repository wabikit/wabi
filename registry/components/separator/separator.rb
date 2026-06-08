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
        if @decorative
          div(
            role: "none",
            **@attrs,
            class: merge_class(tokens(orientation: @orientation), user_class)
          )
        else
          # Use the native <hr> element which carries role=separator implicitly,
          # avoiding the need for an explicit role attribute and satisfying WCAG semantics.
          # border-0 neutralizes Tailwind preflight's default hr border-top so the
          # bg-border line renders identically to the decorative <div> variant.
          hr(
            "aria-orientation": aria_orientation,
            **@attrs,
            class: merge_class(tokens(orientation: @orientation), "border-0", user_class)
          )
        end
      end
    end
  end
end
