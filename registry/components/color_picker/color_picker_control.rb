# frozen_string_literal: true

require "date"

module Components
  module UI
    class ColorPickerControl < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--color-picker-target": "control" },
          class: merge_class("inline-flex items-center gap-2", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
