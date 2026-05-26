# frozen_string_literal: true

require "date"

module Components
  module UI
    # Outline button tagged as the Zag closeTrigger -- click auto-closes the
    # popover via the same `wabi--popover` controller (no manual data-action
    # wiring needed). Matches the DialogCancel / DrawerClose pattern.
    class PopoverClose < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        render Components::UI::Button.new(
          appearance: :outline,
          data: { "wabi--popover-target": "closeTrigger" },
          **@attrs
        ) do
          yield if block_given?
        end
      end
    end
  end
end
