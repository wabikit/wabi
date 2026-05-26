# frozen_string_literal: true

require "date"

module Components
  module UI
    class DropdownMenuItem < Wabi::Base
      variants do
        base "relative flex cursor-default select-none items-center rounded-sm px-2 py-1.5 " \
             "text-sm outline-none transition-colors " \
             "data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground " \
             "data-[disabled]:pointer-events-none data-[disabled]:opacity-50"
      end

      # `value` identifies the item in the Zag menu state machine; it is what
      # the `onSelect({ value })` callback receives, and what determines
      # highlight/selection.
      def initialize(value:, disabled: false, **attrs)
        @value    = value
        @disabled = disabled
        @attrs    = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        user_data  = @attrs.delete(:data) || {}
        div(
          role: "menuitem",
          # User data first, component data second -- component keys win on
          # collision so callers can freely add things like
          # `data: { action: "click->...", foo: "bar" }` without
          # overriding the wabi target / value attributes the controller
          # relies on.
          data: {
            **user_data,
            "wabi--dropdown-menu-target": "item",
            "wabi-value": @value,
            "wabi-disabled": @disabled.to_s,
          },
          class: merge_class(tokens, user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
