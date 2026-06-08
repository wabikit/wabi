# frozen_string_literal: true

require "date"

module Components
  module UI
    class ColorPickerValueSwatch < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        span(
          data: { "wabi--color-picker-target": "valueSwatch" },
          aria: { hidden: "true" },
          class: merge_class("h-4 w-4 rounded border border-input", user_class)
        )
      end
    end
  end
end
