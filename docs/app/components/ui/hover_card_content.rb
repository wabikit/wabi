# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class HoverCardContent < Wabi::Base
      variants do
        base "z-50 w-64 rounded-md border border-input bg-popover p-4 text-popover-foreground shadow-md outline-none " \
             "transition-opacity duration-200 ease-out motion-reduce:transition-none " \
             "data-[state=open]:opacity-100 data-[state=closed]:opacity-0 " \
             "data-[state=closed]:pointer-events-none"
      end

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--hover-card-target": "positioner" },
          class: "z-50 pointer-events-none"
        ) do
          div(
            data: { "wabi--hover-card-target": "content" },
            "data-state": "closed",
            inert: true,
            class: merge_class(tokens, user_class)
          ) do
            yield if block_given?
          end
        end
      end
    end
  end
end
