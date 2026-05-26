# frozen_string_literal: true

require "date"

module Components
  module UI
    class AccordionItem < Wabi::Base
      variants do
        base "border-b border-border"
      end

      def initialize(value:, **attrs)
        @value = value
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          data: {
            "wabi--accordion-target": "item",
            "wabi-value": @value,
          },
          class: merge_class(tokens, user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
