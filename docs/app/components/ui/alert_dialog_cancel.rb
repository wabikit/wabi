# frozen_string_literal: true

require "date"

module Components
  module UI
    # Outlined "Cancel" button. Tagged as a Zag closeTrigger so the dialog
    # closes on click without the caller needing to wire data-action manually.
    class AlertDialogCancel < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        render Components::UI::Button.new(
          appearance: :outline,
          data: { "wabi--alert-dialog-target": "closeTrigger cancel" },
          **@attrs
        ) do
          yield if block_given?
        end
      end
    end
  end
end
