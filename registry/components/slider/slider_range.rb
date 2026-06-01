# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class SliderRange < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        # Cross-axis fill. Horizontal: h-full (Zag sets the width from the
        # value). Vertical (Zag stamps data-orientation): w-full instead, and
        # cancel h-full so Zag's top/bottom define the fill height — otherwise
        # the range has zero width (invisible) and ignores the value.
        div(
          data: { "wabi--slider-target": "range" },
          class: merge_class(
            "absolute h-full bg-primary " \
            "data-[orientation=vertical]:h-auto data-[orientation=vertical]:w-full",
            user_class
          )
        )
      end
    end
  end
end
