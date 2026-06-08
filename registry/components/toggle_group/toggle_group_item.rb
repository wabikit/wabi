# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class ToggleGroupItem < Wabi::Base
      ITEM_CLASS = "inline-flex items-center justify-center rounded-md text-sm font-medium " \
                   "h-9 px-2.5 transition-colors motion-reduce:transition-none " \
                   "hover:bg-muted hover:text-muted-foreground " \
                   "focus-visible:outline-none focus-visible:ring-2 " \
                   "focus-visible:ring-ring focus-visible:ring-offset-2 " \
                   "disabled:pointer-events-none disabled:opacity-50 " \
                   "data-[state=on]:bg-accent data-[state=on]:text-accent-foreground"

      def initialize(value:, disabled: false, **attrs)
        @value    = value
        @disabled = disabled
        @attrs    = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          type: "button",
          **@attrs,
          "data-state": "off",
          data: {
            "wabi--toggle-group-target": "item",
            "wabi-value": @value,
            "wabi-disabled": @disabled.to_s,
          },
          class: merge_class(ITEM_CLASS, user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
