# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class RadioGroupItem < Wabi::Base
      ITEM_CLASS = "inline-flex items-center gap-2 cursor-pointer " \
                   "data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50"

      CONTROL_CLASS = "aspect-square h-4 w-4 rounded-full border border-primary " \
                      "text-primary shadow ring-offset-background " \
                      "focus-visible:outline-none focus-visible:ring-2 " \
                      "focus-visible:ring-ring focus-visible:ring-offset-2 " \
                      "data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50 " \
                      "flex items-center justify-center"

      def initialize(value:, disabled: false, **attrs)
        @value    = value
        @disabled = disabled
        @attrs    = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        label(
          data: {
            "wabi--radio-group-target": "item",
            "wabi-value": @value,
            "wabi-disabled": @disabled.to_s,
          },
          class: merge_class(ITEM_CLASS, user_class)
        ) do
          # Hidden input for form submission (Zag fills in checked + name via getHiddenInputProps).
          input(
            type: "radio",
            value: @value,
            data: { "wabi--radio-group-target": "hiddenInput", "wabi-value": @value },
            class: "sr-only"
          )
          # The control (radio dot container)
          span(
            data: { "wabi--radio-group-target": "itemControl", "wabi-value": @value },
            class: CONTROL_CLASS
          ) do
            render Components::UI::RadioGroupIndicator.new
          end
          # The text label
          span(data: { "wabi--radio-group-target": "itemText", "wabi-value": @value }) do
            yield if block_given?
          end
        end
      end
    end
  end
end
