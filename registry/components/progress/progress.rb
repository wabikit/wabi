# frozen_string_literal: true

module Components
  module UI
    class Progress < Wabi::Base
      variants do
        base "relative h-4 w-full overflow-hidden rounded-full bg-secondary"
      end

      def initialize(value: 0, max: 100, aria_label: "Progress", **attrs)
        @value      = value
        @max        = max
        @aria_label = aria_label
        @attrs      = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        pct = (@value.to_f / @max * 100).clamp(0, 100)
        div(
          role: "progressbar",
          "aria-label": @aria_label,
          "aria-valuemin": "0",
          "aria-valuemax": @max.to_s,
          "aria-valuenow": @value.to_s,
          **@attrs,
          class: merge_class(tokens, user_class)
        ) do
          div(
            class: "h-full w-full flex-1 bg-primary transition-all motion-reduce:transition-none",
            style: "transform: translateX(-#{100 - pct}%)"
          )
        end
      end
    end
  end
end
