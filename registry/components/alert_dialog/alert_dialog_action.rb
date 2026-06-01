# frozen_string_literal: true

require "date"

module Components
  module UI
    # Primary "Confirm" button. Does NOT auto-close -- the caller wires
    # `data-action="click->wabi--alert-dialog#close"` (or their own handler) so they
    # can persist before dismissing.
    class AlertDialogAction < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        render Components::UI::Button.new(**@attrs) do
          yield if block_given?
        end
      end
    end
  end
end
