# frozen_string_literal: true

require "date"

module Components
  module UI
    class TooltipContent < Wabi::Base
      variants do
        base "z-50 overflow-hidden rounded-md bg-primary px-3 py-1.5 text-xs text-primary-foreground shadow-md"
      end

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        # Positioner is `position: absolute` (set by Zag via popperStyles.floating)
        # anchored to the trigger -- NOT a full-viewport overlay like Dialog --
        # so `pointer-events-none` on it just ensures we never block clicks at
        # the trigger's footprint when the tooltip is hidden but the wrapper
        # element still exists in the layout.
        div(
          data: { "wabi--tooltip-target": "positioner" },
          class: "z-50 pointer-events-none"
        ) do
          div(
            data: { "wabi--tooltip-target": "content" },
            hidden: true,
            class: merge_class(tokens, user_class)
          ) do
            yield if block_given?
          end
        end
      end
    end
  end
end
