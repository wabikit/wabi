# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class ComboboxItem < Wabi::Base
      ITEM_CLASS = "relative flex cursor-default select-none items-center rounded-sm py-1.5 px-2 " \
                   "text-sm outline-none " \
                   "data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground " \
                   "data-[disabled]:pointer-events-none data-[disabled]:opacity-50"

      def initialize(value:, disabled: false, **attrs)
        @value    = value
        @disabled = disabled
        @attrs    = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        # data-disabled emitted ONLY when @disabled is true. The Tailwind
        # `data-[disabled]:*` variants match attribute PRESENCE regardless
        # of value, so emitting `data-wabi-disabled="false"` would still trigger
        # the disabled styling — keep it absent in the not-disabled case.
        # When @disabled is true, the SSR attribute matches Zag's hydration
        # output (`isItemDisabled` callback in the controller's collection).
        item_data = {
          "wabi--combobox-target": "item",
          "wabi-value": @value,
        }
        item_data[:disabled] = "true" if @disabled

        li(
          data: item_data,
          class: merge_class(ITEM_CLASS, user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
