# frozen_string_literal: true

require "date"

module Components
  module UI
    class PopoverTrigger < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          type: "button",
          data: { "wabi--popover-target": "trigger" },
          class: user_class
        ) do
          yield if block_given?
        end
      end
    end
  end
end
