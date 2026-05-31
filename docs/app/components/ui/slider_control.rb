# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    # Positioning context for the track + thumb(s). The root is a flex column
    # (label on top, marks below), so thumbs — which Zag positions absolutely —
    # need a short wrapper whose height equals the track's, otherwise they
    # anchor to the tall root and float above the bar. This control is
    # `relative flex items-center` (no overflow-hidden, so the thumb knob can
    # extend past the thin track), and each SliderThumb centers on it.
    class SliderControl < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--slider-target": "control" },
          class: merge_class("relative flex w-full items-center", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
