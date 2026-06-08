# frozen_string_literal: true

require "date"

module Components
  module UI
    class PopoverTrigger < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        # Spread @attrs so callers can pass aria-label: for icon-only triggers.
        # Explicit data: wiring is placed last so Zag's target wire always wins.
        button(
          type: "button",
          **@attrs,
          data: { "wabi--popover-target": "trigger" },
          class: user_class
        ) do
          yield if block_given?
        end
      end
    end
  end
end
