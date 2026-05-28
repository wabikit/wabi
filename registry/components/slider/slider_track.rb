# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class SliderTrack < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--slider-target": "track" },
          class: merge_class(
            "relative h-2 w-full grow overflow-hidden rounded-full bg-secondary " \
            "data-[orientation=vertical]:h-full data-[orientation=vertical]:w-2",
            user_class
          )
        ) do
          yield if block_given?
        end
      end
    end
  end
end
