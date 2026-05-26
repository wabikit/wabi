# frozen_string_literal: true

require "date"

module Components
  module UI
    class Tabs < Wabi::Base
      def initialize(value:, activation_mode: :automatic, id: nil, **attrs)
        @id              = id
        @value           = value
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
          },
          class: user_class
        ) do
          yield if block_given?
        end
      end
    end
  end
end
