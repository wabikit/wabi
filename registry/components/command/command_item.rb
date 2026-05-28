# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class CommandItem < Wabi::Base
      ITEM_CLASS = "relative flex cursor-default select-none items-center rounded-sm py-1.5 px-2 " \
                   "text-sm outline-none gap-2 " \
                   "data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground " \
                   "data-[disabled]:pointer-events-none data-[disabled]:opacity-50"

      def initialize(value:, label: nil, shortcut: nil, disabled: false, **attrs)
        @value    = value
        @label    = label
        @shortcut = shortcut
        @disabled = disabled
        # `:group` is consumed by CommandList; absorbed-and-discarded here.
        attrs.delete(:group)
        @attrs    = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        li(
          **@attrs,
          data: {
            "wabi--combobox-target": "item",
            "wabi-value": @value,
            "wabi-disabled": @disabled.to_s,
          },
          class: merge_class(ITEM_CLASS, user_class)
        ) do
          if block_given?
            yield
          elsif @label
            plain @label
          end
          if @shortcut
            span(class: "ml-auto text-xs text-muted-foreground") { @shortcut }
          end
        end
      end
    end
  end
end
