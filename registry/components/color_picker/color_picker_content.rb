# frozen_string_literal: true

require "date"

module Components
  module UI
    class ColorPickerContent < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--color-picker-target": "positioner" },
          class: "z-50 pointer-events-none"
        ) do
          div(
            data: { "wabi--color-picker-target": "content" },
            "data-state": "closed",
            inert: true,
            class: merge_class(
              "z-50 w-64 rounded-md border border-input bg-popover p-3 text-popover-foreground shadow-md outline-none " \
              "transition-opacity duration-200 ease-out motion-reduce:transition-none " \
              "data-[state=open]:opacity-100 data-[state=closed]:opacity-0 data-[state=closed]:pointer-events-none",
              user_class
            )
          ) do
            yield if block_given?
          end
        end
      end
    end
  end
end
