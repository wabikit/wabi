# frozen_string_literal: true

require "date"

module Components
  module UI
    class DrawerTrigger < Wabi::Base
      # @param aria_label [String, nil] Accessible label forwarded as aria-label
      #   on the underlying button.  Required when the trigger slot contains only
      #   an icon (e.g. a hamburger SVG with no visible text); omit when the slot
      #   contains descriptive text.
      #   Example:
      #     DrawerTrigger.new(aria_label: "Open navigation menu") { hamburger_icon }
      def initialize(aria_label: nil, **attrs)
        @aria_label = aria_label
        @attrs      = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          type: "button",
          aria_label: @aria_label,
          data: { "wabi--dialog-target": "trigger" },
          class: user_class,
          **@attrs
        ) do
          yield if block_given?
        end
      end
    end
  end
end
