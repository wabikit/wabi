# frozen_string_literal: true

require "date"

module Components
  module UI
    class TooltipContent < Wabi::Base
      variants do
        base "z-50 overflow-hidden rounded-md bg-primary px-3 py-1.5 text-xs text-primary-foreground shadow-md " \
             "transition-opacity duration-150 ease-out motion-reduce:transition-none " \
             "data-[state=open]:opacity-100 data-[state=closed]:opacity-0 " \
             "data-[state=closed]:pointer-events-none"
      end

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        # Visibility via data-state + opacity transition rather than `hidden`,
        # so fade-in / fade-out actually run instead of snapping. Controller
        # mirrors `inert` on the content based on api.open.
        div(
          data: { "wabi--tooltip-target": "positioner" },
          class: "z-50 pointer-events-none"
        ) do
          div(
            data: { "wabi--tooltip-target": "content" },
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
