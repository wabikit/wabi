# frozen_string_literal: true

require "date"

module Components
  module UI
    class TabsTrigger < Wabi::Base
      variants do
        base "inline-flex items-center justify-center whitespace-nowrap rounded-sm px-3 py-1.5 " \
             "text-sm font-medium transition-all cursor-pointer focus-visible:outline-none " \
             "focus-visible:ring-2 focus-visible:ring-ring " \
             "disabled:pointer-events-none disabled:opacity-50 disabled:cursor-not-allowed " \
             "aria-selected:bg-background aria-selected:text-foreground " \
             "aria-selected:shadow-sm"
      end

      def initialize(value:, disabled: false, **attrs)
        @value    = value
        @disabled = disabled
        @attrs    = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          type: "button",
          role: "tab",
          data: {
            "wabi--tabs-target": "trigger",
            "wabi-value": @value,
            "wabi-disabled": @disabled.to_s,
          },
          class: merge_class(tokens, user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
