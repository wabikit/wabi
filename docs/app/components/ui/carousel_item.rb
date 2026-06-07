# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class CarouselItem < Wabi::Base
      def initialize(index:, **attrs)
        @index = index
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--carousel-target": "item", "wabi-index": @index.to_s },
          class: merge_class("min-w-0 shrink-0 grow-0 basis-full", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
