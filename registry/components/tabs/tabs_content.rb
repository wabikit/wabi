# frozen_string_literal: true

require "date"

module Components
  module UI
    class TabsContent < Wabi::Base
      variants do
        base "mt-2 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
      end

      def initialize(value:, **attrs)
        @value = value
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          role: "tabpanel",
          data: {
            "wabi--tabs-target": "content",
            "wabi-value": @value,
          },
          hidden: true,
          tabindex: 0,
          class: merge_class(tokens, user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
