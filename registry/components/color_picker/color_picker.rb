# frozen_string_literal: true

require "date"

module Components
  module UI
    class ColorPicker < Wabi::Base
      def initialize(id: nil, value: "#000000", format: "rgba", name: nil, **attrs)
        @id     = id
        @value  = value
        @format = format
        @name   = name
        @attrs  = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          id: @id,
          data: {
            controller: "wabi--color-picker",
            "wabi--color-picker-value-value":  @value.to_s,
            "wabi--color-picker-format-value": @format.to_s,
            "wabi--color-picker-name-value":   @name.to_s,
          },
          class: merge_class("relative inline-block", user_class)
        ) do
          yield if block_given?
          if @name
            input(
              type: "hidden",
              name: @name,
              value: @value.to_s,
              data: { "wabi--color-picker-target": "hiddenInput" }
            )
          end
        end
      end
    end
  end
end
