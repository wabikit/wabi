# frozen_string_literal: true

require "date"

module Components
  module UI
    # Wraps RadioItems so that selecting one auto-unselects the others within
    # the same group. `name` identifies the group; each child RadioItem inherits
    # this `name` via `<div role="group">` ancestry (the controller reads
    # `data-wabi-name` from the radio item ancestor).
    class ContextMenuRadioGroup < Wabi::Base
      # label: optional accessible name for the radio group. When provided,
      # aria-label is added to the group div so screen readers announce the
      # group name (e.g. label: "Theme"). Alternatively, pair a ContextMenuLabel
      # id with aria-labelledby on this element for a visible label association.
      def initialize(name:, value: nil, label: nil, **attrs)
        @name  = name
        @value = value
        @label = label
        @attrs = attrs
      end

      def view_template(&block)
        div(
          role: "group",
          aria_label: @label,
          data: {
            "wabi--context-menu-target": "radioGroup",
            "wabi-name":  @name,
            "wabi-value": @value.to_s,
          }
        ) do
          yield if block_given?
        end
      end
    end
  end
end
