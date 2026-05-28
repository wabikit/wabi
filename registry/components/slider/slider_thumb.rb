# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class SliderThumb < Wabi::Base
      THUMB_CLASS = "block h-5 w-5 rounded-full border-2 border-primary bg-background " \
                    "ring-offset-background transition-colors " \
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
