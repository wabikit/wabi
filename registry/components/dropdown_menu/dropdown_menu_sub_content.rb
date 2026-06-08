# frozen_string_literal: true

require "date"

module Components
  module UI
    # Floating sub-content. Mirrors DropdownMenuContent's shape: a positioner
    # wrapper + a content child. The parent controller routes Zag props onto
    # `subPositioner` / `subContent` instead of `positioner` / `content` so
    # the parent menu's own content stays untouched.
    class DropdownMenuSubContent < Wabi::Base
      variants do
        base "z-50 min-w-[8rem] overflow-hidden rounded-md border border-input bg-popover p-1 " \
             "text-popover-foreground shadow-md outline-none " \
             "transition-opacity duration-150 ease-out motion-reduce:transition-none " \
             "data-[state=open]:opacity-100 data-[state=closed]:opacity-0 " \
             "data-[state=closed]:pointer-events-none"
      end

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--dropdown-menu-target": "subPositioner" },
          class: "z-50 pointer-events-none"
        ) do
          div(
            data: { "wabi--dropdown-menu-target": "subContent" },
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
