# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class CarouselItemGroup < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--carousel-target": "itemGroup" },
          class: merge_class("flex", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
