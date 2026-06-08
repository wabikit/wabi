# frozen_string_literal: true

require "date"

module Components
  module UI
    class ColorPickerSwatchGroup < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--color-picker-target": "swatchGroup" },
          class: merge_class("mt-3 flex flex-wrap gap-1.5", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
