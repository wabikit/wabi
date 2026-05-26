# frozen_string_literal: true

require "date"

module Components
  module UI
    class SelectItem < Wabi::Base
      variants do
        base "relative flex w-full cursor-default select-none items-center rounded-sm " \
             "py-1.5 pl-8 pr-2 text-sm outline-none " \
             "data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground " \
             "data-[disabled]:pointer-events-none data-[disabled]:opacity-50 " \
             "data-[state=checked]:font-medium"
      end

      def initialize(value:, **attrs)
        @value = value
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        li(
          role: "option",
          data: {
            "wabi--select-target": "item",
            "wabi-value": @value,
          },
          class: merge_class(tokens, user_class)
        ) do
          # Item indicator (checkmark) — shown only on the selected item.
          span(
            data: { "wabi--select-target": "itemIndicator" },
            class: "absolute left-2 flex h-3.5 w-3.5 items-center justify-center",
            hidden: true
          ) do
            raw(safe('<svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>'))
          end
          span(data: { "wabi--select-target": "itemText" }) do
            yield if block_given?
          end
        end
      end
    end
  end
end
