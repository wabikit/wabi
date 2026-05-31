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
            # inline; the authored classes match that (relative + full width/height).
            # Horizontal: the group reserves height (h-9) so ticks + labels sit in a
            # row below the track; each marker is a column (tick above, label below).
            # Vertical: the group runs full height alongside the rail; each marker is
            # a row (tick left, label to the right) since Zag positions vertical
            # markers along the Y axis via `bottom`.
            vertical     = @orientation == :vertical
            group_class  = vertical ? "relative h-full ml-1 pointer-events-none" : "relative w-full h-9 mt-1 pointer-events-none"
            marker_class = vertical ? "absolute flex items-center" : "absolute flex flex-col items-center"
            tick_class   = vertical ? "block h-0.5 w-2 rounded-full bg-muted-foreground" : "block h-2 w-0.5 rounded-full bg-muted-foreground"
            label_class  = vertical ? "ml-2 block text-xs text-muted-foreground whitespace-nowrap" : "mt-1 block text-xs text-muted-foreground whitespace-nowrap"
            div(data: { "wabi--slider-target": "markerGroup" }, class: group_class) do
              @marks.each do |mark|
                div(
                  data: { "wabi--slider-target": "marker", "wabi-mark-value": mark[:value].to_s },
                  class: marker_class
                ) do
                  span(class: tick_class) {}
                  span(class: label_class) { mark[:label] } if mark[:label]
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
