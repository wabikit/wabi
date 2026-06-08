# frozen_string_literal: true

require "date"

module Components
  module UI
    class InputOtp < Wabi::Base
      SLOT_CLASS =
        "h-10 w-10 rounded-md border border-input bg-background text-center text-base " \
        "shadow-sm transition-colors motion-reduce:transition-none outline-none " \
        "focus-visible:border-ring focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 ring-offset-background " \
        "disabled:cursor-not-allowed disabled:opacity-50"

      def initialize(name:, length: 6, type: :numeric, mask: false, otp: true,
                     default_value: nil, placeholder: "○", disabled: false,
                     invalid: false, required: false,
                     label: "One-time passcode", **attrs)
        @name          = name
        @length        = length
        @type          = type
        @mask          = mask
        @otp           = otp
        @default_value = default_value
        @placeholder   = placeholder
        @disabled      = disabled
        @invalid       = invalid
        @required      = required
        @label         = label
        @attrs         = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        user_data  = @attrs.delete(:data) || {}
        root_data = {
          controller: "wabi--input-otp",
          "wabi--input-otp-name-value":          @name,
          "wabi--input-otp-length-value":        @length.to_s,
          "wabi--input-otp-type-value":          @type.to_s,
          "wabi--input-otp-mask-value":          @mask.to_s,
          "wabi--input-otp-otp-value":           @otp.to_s,
          "wabi--input-otp-default-value-value": @default_value.to_s,
          "wabi--input-otp-disabled-value":      @disabled.to_s,
          "wabi--input-otp-invalid-value":       @invalid.to_s,
          "wabi--input-otp-required-value":      @required.to_s,
        }
        # aria-label names the group of slots; each slot also gets a per-digit
        # aria-label at runtime via the controller's Zag `translations.inputLabel`.
        div(**@attrs, "aria-label": @label, data: user_data.merge(root_data),
            class: merge_class("inline-flex items-center gap-2", user_class)) do
          @length.times do
            input(
              type: "text", inputmode: @type == :numeric ? "numeric" : "text",
              autocomplete: @otp ? "one-time-code" : "off",
              placeholder: @placeholder,
              data: { "wabi--input-otp-target": "slot" },
              class: SLOT_CLASS
            )
          end
          input(type: "hidden", name: @name, data: { "wabi--input-otp-target": "hiddenValue" })
        end
      end
    end
  end
end
