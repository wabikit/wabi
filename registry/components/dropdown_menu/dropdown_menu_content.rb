# frozen_string_literal: true

require "date"

module Components
  module UI
    class DropdownMenuContent < Wabi::Base
      variants do
        base "z-50 min-w-[8rem] overflow-hidden rounded-md border-input bg-popover p-1 " \
             "text-popover-foreground shadow-md outline-none"
      end

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        # Positioner uses Zag floating-ui (position:absolute anchored to trigger),
        # NOT a full-viewport overlay -- same shape as Tooltip/Popover. `pointer-
        # events-none` on the positioner is defensive. `hidden: !open` lives on
        # the content per Zag's `getContentProps`.
        div(
          data: { "wabi--dropdown-menu-target": "positioner" },
          class: "z-50 pointer-events-none"
        ) do
          div(
            data: { "wabi--dropdown-menu-target": "content" },
            hidden: true,
            class: merge_class(tokens, user_class)
          ) do
            yield if block_given?
          end
        end
      end
    end
  end
end
