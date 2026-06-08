# frozen_string_literal: true

require "date"

module Components
  module UI
    class ColorPickerSwatch < Wabi::Base
      def initialize(value:, **attrs)
        @value = value
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        button(
          type: "button",
          data: { "wabi--color-picker-target": "swatch", "wabi-value": @value.to_s },
          class: merge_class("relative h-6 w-6 rounded border border-input", user_class)
        ) do
          div(
            data: { "wabi--color-picker-swatch": "bg" },
            class: "h-full w-full rounded"
          )
          div(
            data: { "wabi--color-picker-swatch": "indicator" },
            class: "absolute inset-0 grid place-items-center text-xs text-white"
          ) { raw(safe("&check;")) }
        end
      end
    end
  end
end
