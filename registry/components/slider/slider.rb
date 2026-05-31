# frozen_string_literal: true

require "json"
require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class Slider < Wabi::Base
      def initialize(name:, value:, min: 0, max: 100, step: 1, orientation: :horizontal, disabled: false, **attrs)
        @name        = name
        @value       = Array(value).compact
        @min         = min
        @max         = max
        @step        = step
        @orientation = orientation
        @disabled    = disabled
        @attrs       = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          **@attrs,
          data: {
            controller: "wabi--slider",
            "wabi--slider-name-value":        @name,
            "wabi--slider-value-value":       @value.to_json,
            "wabi--slider-min-value":         @min.to_s,
            "wabi--slider-max-value":         @max.to_s,
            "wabi--slider-step-value":        @step.to_s,
            "wabi--slider-orientation-value": @orientation.to_s,
            "wabi--slider-disabled-value":    @disabled.to_s,
          },
          class: merge_class(layout_class, user_class)
        ) do
          yield if block
        end
      end

      private

      def layout_class
        @orientation == :vertical ? "relative flex flex-col items-center h-48 w-5" : "relative flex flex-col w-full"
      end
    end
  end
end
