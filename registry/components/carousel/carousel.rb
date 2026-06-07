# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class Carousel < Wabi::Base
      def initialize(slide_count:, slides_per_page: 1, slides_per_move: 1, loop: false, orientation: :horizontal, autoplay: false, **attrs)
        @slide_count     = slide_count
        @slides_per_page = slides_per_page
        @slides_per_move = slides_per_move
        @loop            = loop
        @orientation     = orientation
        @autoplay        = autoplay
        @attrs           = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          **@attrs,
          data: {
            controller: "wabi--carousel",
            "wabi--carousel-slide-count-value":     @slide_count.to_s,
            "wabi--carousel-slides-per-page-value": @slides_per_page.to_s,
            "wabi--carousel-slides-per-move-value": @slides_per_move.to_s,
            "wabi--carousel-loop-value":            @loop.to_s,
            "wabi--carousel-orientation-value":     @orientation.to_s,
            "wabi--carousel-autoplay-value":        @autoplay.to_s,
          },
          class: merge_class("relative w-full", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
