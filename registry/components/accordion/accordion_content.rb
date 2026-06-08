# frozen_string_literal: true

require "date"

module Components
  module UI
    # Content uses a CSS-grid height-animation trick: outer is `grid` with
    # `grid-rows-[0fr]` when closed and `grid-rows-[1fr]` when open, animating
    # `grid-template-rows`. The inner wrapper is `overflow-hidden` so the body
    # is clipped during the transition. No keyframes / no tailwindcss-animate
    # needed -- works in Chrome 117+, Safari 17.4+, Firefox 119+.
    #
    # `hidden:false` is forced by the controller after Zag's spreadProps to
    # keep transitions from being short-circuited by `display:none` (same
    # pattern Sprint 4 cleanup adopted for the overlays).
    class AccordionContent < Wabi::Base
      variants do
        base "grid text-sm transition-[grid-template-rows] duration-200 ease-out motion-reduce:transition-none " \
             "data-[state=closed]:grid-rows-[0fr] data-[state=open]:grid-rows-[1fr]"
      end

      def initialize(value:, **attrs)
        @value = value
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          "data-state": "closed",
          data: {
            "wabi--accordion-target": "content",
            "wabi-value": @value,
          },
          class: merge_class(tokens, user_class)
        ) do
          div(class: "overflow-hidden") do
            div(class: "pb-4 pt-0") do
              yield if block_given?
            end
          end
        end
      end
    end
  end
end
