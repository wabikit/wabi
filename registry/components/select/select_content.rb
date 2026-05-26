# frozen_string_literal: true

require "date"

module Components
  module UI
    class SelectContent < Wabi::Base
      variants do
        base "z-50 max-h-96 min-w-[8rem] overflow-hidden rounded-md border-input " \
             "bg-popover text-popover-foreground shadow-md " \
             "transition-opacity duration-150 ease-out " \
             "data-[state=open]:opacity-100 data-[state=closed]:opacity-0 " \
             "data-[state=closed]:pointer-events-none"
      end

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--select-target": "positioner" },
          class: "z-50"
        ) do
          div(
            data: { "wabi--select-target": "content" },
            "data-state": "closed",
            class: merge_class(tokens, user_class)
          ) do
            ul(
              data: { "wabi--select-target": "list" },
              class: "p-1"
            ) do
              yield if block_given?
            end
          end
        end
      end
    end
  end
end
