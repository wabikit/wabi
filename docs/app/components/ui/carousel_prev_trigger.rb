# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class CarouselPrevTrigger < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          type: "button",
          "aria-label": "Previous slide",
          data: { "wabi--carousel-target": "prevTrigger" },
          class: merge_class(
            "inline-flex h-8 w-8 items-center justify-center rounded-full border border-input " \
            "disabled:pointer-events-none disabled:opacity-40",
            user_class
          )
        ) do
          if block_given?
            yield
          else
            raw safe(%(<svg aria-hidden="true" focusable="false" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="h-4 w-4"><path d="m15 18-6-6 6-6"/></svg>))
          end
        end
      end
    end
  end
end
