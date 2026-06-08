# frozen_string_literal: true

require "date"

module Components
  module UI
    class ColorPickerArea < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--color-picker-target": "area" },
          class: merge_class("relative h-40 w-full rounded-md", user_class)
        ) do
          div(
            data: { "wabi--color-picker-target": "areaBackground" },
            class: "absolute inset-0 rounded-md"
          )
          div(
            data: { "wabi--color-picker-target": "areaThumb" },
            class: "absolute h-4 w-4 -translate-x-1/2 -translate-y-1/2 rounded-full border-2 border-white shadow"
          )
        end
      end
    end
  end
end
