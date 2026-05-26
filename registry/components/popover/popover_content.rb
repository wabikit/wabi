# frozen_string_literal: true

require "date"

module Components
  module UI
    class PopoverContent < Wabi::Base
      variants do
        base "z-50 w-72 rounded-md border-input bg-popover p-4 text-popover-foreground shadow-md outline-none"
      end

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        # Positioner is `position: absolute` (Zag floating-ui), anchored to the
        # trigger -- not a full-viewport overlay. `pointer-events-none` is
        # defensive: even though the positioner has no visible footprint when
        # the content inside is `hidden`, this guarantees zero click intercept
        # in any edge case (e.g., a popover briefly visible during transition).
        div(
          data: { "wabi--popover-target": "positioner" },
          class: "z-50 pointer-events-none"
        ) do
          div(
            data: { "wabi--popover-target": "content" },
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
