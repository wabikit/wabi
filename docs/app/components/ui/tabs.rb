# frozen_string_literal: true

require "date"

module Components
  module UI
    class Tabs < Wabi::Base
      def initialize(value:, variant: :standard, activation_mode: :automatic, id: nil, **attrs)
        @id              = id
        @value           = value
        @variant         = variant
        @activation_mode = activation_mode
        @attrs           = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          id: @id,
          data: {
            controller: "wabi--tabs",
            "wabi--tabs-value-value": @value,
            "wabi--tabs-activation-mode-value": @activation_mode.to_s,
            variant: @variant.to_s,
          },
          class: merge_class("group/tabs", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
