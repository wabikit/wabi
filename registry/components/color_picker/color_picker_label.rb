# frozen_string_literal: true

require "date"

module Components
  module UI
    class ColorPickerLabel < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        label(
          data: { "wabi--color-picker-target": "label" },
          class: merge_class("text-sm font-medium", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
