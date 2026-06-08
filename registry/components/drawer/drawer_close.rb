# frozen_string_literal: true

require "date"

module Components
  module UI
    # Outline button tagged as the Zag closeTrigger -- click auto-closes the
    # drawer via the same `wabi--dialog` controller (no manual data-action wiring
    # needed). Matches the DialogCancel pattern.
    #
    # WCAG AA (4.1.2 / 1.1.1): When the slot contains only an icon (e.g. an X
    # SVG with no visible text) the button would have no accessible name.
    # Pass `aria_label:` to override the default "Close" label.
    # Example:
    #   DrawerClose.new(aria_label: "Close settings drawer") { x_icon }
    class DrawerClose < Wabi::Base
      # @param aria_label [String, nil] Accessible label forwarded as aria-label
      #   on the underlying button.  Defaults to "Close" so icon-only close
      #   buttons are always named; callers may override with a more specific
      #   description (e.g. "Close settings drawer").
      def initialize(aria_label: nil, **attrs)
        @aria_label = aria_label
        @attrs      = attrs
      end

      def view_template(&block)
        # Merge caller-supplied aria: hash (if any) with our default label so
        # neither side silently wins.
        caller_aria  = @attrs.delete(:aria) || {}
        resolved_aria = { label: @aria_label || "Close" }.merge(caller_aria)

        render Components::UI::Button.new(
          appearance: :outline,
          aria:       resolved_aria,
          data:       { "wabi--dialog-target": "closeTrigger" },
          **@attrs
        ) do
          yield if block_given?
        end
      end
    end
  end
end
