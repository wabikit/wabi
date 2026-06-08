# frozen_string_literal: true

require "date"

module Components
  module UI
    # Toggle-style menu item. Renders with `role="menuitemcheckbox"` and toggles
    # its own `data-state`/`aria-checked` on click via the parent
    # `wabi--dropdown-menu` controller (no extra Stimulus action wiring needed).
    class DropdownMenuCheckboxItem < Wabi::Base
      variants do
        base "relative flex cursor-default select-none items-center rounded-sm py-1.5 pl-8 pr-2 " \
             "text-sm outline-none transition-colors " \
             "data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground " \
             "data-[disabled]:pointer-events-none data-[disabled]:opacity-50"
      end

      def initialize(value:, checked: false, disabled: false, **attrs)
        @value    = value
        @checked  = checked
        @disabled = disabled
        @attrs    = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          role: "menuitemcheckbox",
          "data-state": @checked ? "checked" : "unchecked",
          "aria-checked": @checked.to_s,
          data: {
            "wabi--dropdown-menu-target": "optionItem",
            "wabi-value":   @value,
            "wabi-type":    "checkbox",
            "wabi-checked": @checked.to_s,
            "wabi-disabled": @disabled.to_s,
          },
          class: merge_class(tokens, user_class)
        ) do
          # Indicator (checkmark). Shown when data-state=checked; the controller
          # toggles `hidden` directly on this span each render. Could also be
          # done via Tailwind 4 group-data variants -- explicit hidden toggle
          # keeps the controller logic uniform.
          span(
            data: { "wabi--dropdown-menu-target": "optionItemIndicator" },
            hidden: !@checked,
            class: "absolute left-2 flex h-3.5 w-3.5 items-center justify-center"
          ) do
            raw(safe('<svg aria-hidden="true" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>'))
          end
          yield if block_given?
        end
      end
    end
  end
end
