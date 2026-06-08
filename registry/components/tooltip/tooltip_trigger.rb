# frozen_string_literal: true

require "date"

module Components
  module UI
    class TooltipTrigger < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        # Spread remaining caller attrs (e.g. aria-label for icon-only triggers)
        # after extracting :class so callers can pass aria-label: "…" etc.
        button(
          type: "button",
          data: { "wabi--tooltip-target": "trigger" },
          class: user_class,
          **@attrs
        ) do
          yield if block_given?
        end
      end
    end
  end
end
