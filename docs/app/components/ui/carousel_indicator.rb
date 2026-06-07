# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class CarouselIndicator < Wabi::Base
      def initialize(index:, **attrs)
        @index = index
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        button(
          type: "button",
          "aria-label": "Go to slide #{@index.to_i + 1}",
          data: { "wabi--carousel-target": "indicator", "wabi-index": @index.to_s },
          class: merge_class(
            "h-2 w-2 rounded-full bg-border transition-colors data-[current]:bg-primary",
            user_class
          )
        )
      end
    end
  end
end
