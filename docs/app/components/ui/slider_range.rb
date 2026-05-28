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
        div(
          data: { "wabi--slider-target": "range" },
          class: merge_class("absolute h-full bg-primary", user_class)
        )
      end
    end
  end
end
