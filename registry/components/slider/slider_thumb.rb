# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class SliderThumb < Wabi::Base
      # Cross-axis centering on the rail. Horizontal: center vertically
      # (top-1/2 -translate-y-1/2). Vertical (Zag stamps data-orientation):
      # center horizontally instead (left-1/2 -translate-x-1/2), undoing the
      # horizontal offsets.
      THUMB_CLASS = "block h-3 w-3 rounded-full border border-primary bg-foreground shadow-sm " \
                    "top-1/2 -translate-y-1/2 " \
                    "data-[orientation=vertical]:top-auto data-[orientation=vertical]:left-1/2 " \
                    "data-[orientation=vertical]:translate-y-0 data-[orientation=vertical]:-translate-x-1/2 " \
                    "ring-offset-background transition-colors motion-reduce:transition-none " \
                    "focus-visible:outline-none focus-visible:ring-2 " \
                    "focus-visible:ring-ring focus-visible:ring-offset-2 " \
                    "disabled:pointer-events-none disabled:opacity-50"

      def initialize(index:, **attrs)
        @index = index
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        span(
          role: "slider",
          data: {
            "wabi--slider-target": "thumb",
            "wabi-index": @index.to_s,
          },
          class: merge_class(THUMB_CLASS, user_class)
        )
      end
    end
  end
end
