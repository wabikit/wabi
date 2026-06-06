# frozen_string_literal: true

require "date"

module Components
  module UI
    # Wraps RadioItems so that selecting one auto-unselects the others within
    # the same group. `name` identifies the group; each child RadioItem inherits
    # this `name` via `<div role="group">` ancestry (the controller reads
    # `data-wabi-name` from the radio item ancestor).
    class ContextMenuRadioGroup < Wabi::Base
      def initialize(name:, value: nil, **attrs)
        @name  = name
        @value = value
        @attrs = attrs
      end

      def view_template(&block)
        div(
          role: "group",
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
