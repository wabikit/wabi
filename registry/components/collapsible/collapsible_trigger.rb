# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class CollapsibleTrigger < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          type: "button",
          data: { "wabi--collapsible-target": "trigger" },
          class: merge_class(
            "inline-flex items-center justify-between gap-2 text-sm font-medium " \
            "ring-offset-background focus-visible:outline-none focus-visible:ring-2 " \
            "focus-visible:ring-ring focus-visible:ring-offset-2 " \
            "disabled:pointer-events-none disabled:opacity-50",
            user_class
          )
        ) do
          yield if block_given?
        end
      end
    end
  end
end
