# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class RadioGroup < Wabi::Base
      def initialize(name:, value: nil, disabled: false, **attrs)
        @name     = name
        @value    = value
        @disabled = disabled
        @attrs    = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          **@attrs,
          role: "radiogroup",
          data: {
            controller: "wabi--radio-group",
            "wabi--radio-group-name-value":     @name,
            "wabi--radio-group-value-value":    @value,
            "wabi--radio-group-disabled-value": @disabled.to_s,
          },
          class: merge_class("grid gap-2", user_class),
          &block
        )
      end
    end
  end
end
