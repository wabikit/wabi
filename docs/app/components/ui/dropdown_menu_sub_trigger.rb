# frozen_string_literal: true

require "date"

module Components
  module UI
    # Sub-menu trigger: an item in the parent menu that ALSO opens a
    # submenu on hover / arrow-right. The parent controller applies
    # `parentApi.getTriggerItemProps(childApi)` to merge item + trigger
    # behavior. Rotates via `data-state=open` styling -- Zag toggles the
    # data attribute synchronously on hover.
    class DropdownMenuSubTrigger < Wabi::Base
      variants do
        base "relative flex cursor-default select-none items-center rounded-sm px-2 py-1.5 " \
             "text-sm outline-none transition-colors " \
             "data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground " \
             "data-[state=open]:bg-accent data-[state=open]:text-accent-foreground " \
             "data-[disabled]:pointer-events-none data-[disabled]:opacity-50"
      end

      def initialize(value:, disabled: false, **attrs)
        @value    = value
        @disabled = disabled
        @attrs    = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          role: "menuitem",
          "aria-haspopup": "menu",
          data: {
            "wabi--dropdown-menu-target": "subTrigger",
            "wabi-value":    @value,
            "wabi-disabled": @disabled.to_s,
          },
          class: merge_class(tokens, user_class)
        ) do
          yield if block_given?
          raw(safe('<svg aria-hidden="true" class="ml-auto h-4 w-4 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"/></svg>'))
        end
      end
    end
  end
end
