# frozen_string_literal: true

require "json"
require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class Slider < Wabi::Base
      def initialize(name:, value:, min: 0, max: 100, step: 1, orientation: :horizontal, disabled: false, marks: [], **attrs)
        @name        = name
        @value       = Array(value).compact
        @min         = min
        @max         = max
        @step        = step
        @orientation = orientation
        @disabled    = disabled
        @marks       = Array(marks).map { |m| m.is_a?(Hash) ? m : { value: m, label: nil } }
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
          if @marks.any?
            # Zag's getMarkerGroupProps spreads position:relative + pointer-events:none
            # inline; the authored classes match that (relative + full width) so the
            # markup intent and runtime layout agree. Each marker is absolutely
            # positioned by Zag via inset-inline-start.
            # NOTE: the `mt-2` label offset assumes horizontal orientation; vertical
            # sliders need a horizontal (ml-*) offset instead — deferred follow-up.
            div(data: { "wabi--slider-target": "markerGroup" }, class: "relative w-full pointer-events-none") do
              @marks.each do |mark|
                div(
                  data: { "wabi--slider-target": "marker", "wabi-mark-value": mark[:value].to_s },
                  class: "absolute"
                ) do
                  span(class: "block h-1 w-1 rounded-full bg-muted-foreground") {}
                  span(class: "mt-2 block text-xs text-muted-foreground whitespace-nowrap") { mark[:label] } if mark[:label]
                end
              end
            end
          end
        end
      end

      private

      def layout_class
        @orientation == :vertical ? "relative flex flex-col items-center h-48 w-5" : "relative flex flex-col w-full"
      end
    end
  end
end
