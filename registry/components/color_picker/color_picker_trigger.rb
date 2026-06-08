# frozen_string_literal: true

require "date"

module Components
  module UI
    class ColorPickerTrigger < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          type: "button",
          data: { "wabi--color-picker-target": "trigger" },
          class: merge_class(
            "inline-flex items-center gap-2 rounded-md border border-input bg-background " \
            "px-3 py-2 text-sm hover:bg-accent hover:text-accent-foreground " \
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
            user_class
          )
        ) do
          yield if block_given?
        end
      end
    end
  end
end
