# frozen_string_literal: true

require "date"

module Components
  module UI
    class SelectContent < Wabi::Base
      variants do
        base "z-50 max-h-96 min-w-[8rem] overflow-hidden rounded-md border-input " \
             "bg-popover text-popover-foreground shadow-md"
      end

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        # Positioner is the floating wrapper Zag positions via floating-ui.
        # Content is the toggled surface (Zag spreads `hidden: !open` here, NOT
        # on the positioner -- if you set `hidden` on the positioner it cascades
        # via display:none and the content can never become visible). List wraps
        # the role=listbox.
        div(
          data: { "wabi--select-target": "positioner" },
          class: "z-50"
        ) do
          div(
            data: { "wabi--select-target": "content" },
            hidden: true,
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
