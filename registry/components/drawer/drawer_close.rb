# frozen_string_literal: true

require "date"

module Components
  module UI
    # Outline button tagged as the Zag closeTrigger -- click auto-closes the
    # drawer via the same `wabi--dialog` controller (no manual data-action wiring
    # needed). Matches the DialogCancel pattern.
    class DrawerClose < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        render Components::UI::Button.new(
          appearance: :outline,
          data: { "wabi--dialog-target": "closeTrigger" },
          **@attrs
        ) do
          yield if block_given?
        end
      end
    end
  end
end
