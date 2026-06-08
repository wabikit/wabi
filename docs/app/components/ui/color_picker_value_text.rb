# frozen_string_literal: true

require "date"

module Components
  module UI
    class ColorPickerValueText < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        span(
          data: { "wabi--color-picker-target": "valueText" },
          class: merge_class("text-sm tabular-nums", user_class)
        )
      end
    end
  end
end
