# frozen_string_literal: true

require "date"

module Components
  module UI
    # Mutually-exclusive menu item. Renders with `role="menuitemradio"` and
    # registers itself with its enclosing `ContextMenuRadioGroup` via the
    # `name` argument -- selecting one radio in the same group automatically
    # unselects the rest. Initial selection comes from the RadioGroup's
    # `value:` matching this item's `value:`.
    class ContextMenuRadioItem < Wabi::Base
      variants do
        base "relative flex cursor-default select-none items-center rounded-sm py-1.5 pl-8 pr-2 " \
             "text-sm outline-none transition-colors " \
             "data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground " \
             "data-[disabled]:pointer-events-none data-[disabled]:opacity-50"
      end

      def initialize(value:, name:, checked: false, disabled: false, **attrs)
        @value    = value
        @name     = name
        @checked  = checked
        @disabled = disabled
        @attrs    = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        user_data  = @attrs.delete(:data) || {}
        div(
          role: "menuitemradio",
          "data-state": @checked ? "checked" : "unchecked",
          "aria-checked": @checked.to_s,
          # User data first, component data second -- component keys win on
          # collision so callers can add `data: { action: "click->..." }`
          # without clobbering the wabi target attributes the controller
          # relies on for state routing.
          data: {
            **user_data,
            "wabi--context-menu-target": "optionItem",
            "wabi-value":    @value,
            "wabi-name":     @name,
            "wabi-type":     "radio",
            "wabi-checked":  @checked.to_s,
            "wabi-disabled": @disabled.to_s,
          },
          class: merge_class(tokens, user_class)
        ) do
          span(
            data: { "wabi--context-menu-target": "optionItemIndicator" },
            hidden: !@checked,
            class: "absolute left-2 flex h-3.5 w-3.5 items-center justify-center"
          ) do
            raw(safe('<svg class="h-2 w-2 fill-current" viewBox="0 0 8 8"><circle cx="4" cy="4" r="3"/></svg>'))
          end
          yield if block_given?
        end
      end
    end
  end
end
