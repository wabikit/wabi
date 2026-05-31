# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    # Positioning context for the track + thumb(s). The root is a flex column
    # (label on top, marks below), so thumbs — which Zag positions absolutely —
    # need a wrapper whose size matches the track's, otherwise they anchor to
    # the tall root and float off the bar. No overflow-hidden, so the thumb knob
    # can extend past the thin track.
    #
    # Horizontal: a `flex items-center w-full` row whose height collapses to the
    # track's. Vertical: h-full flex-col fills the root's height — otherwise
    # the control collapses to height 0 and the vertical track (h-full) renders
    # 0px tall.
    #
    # Marks render INSIDE the control (the track's positioning context) and are
    # absolutely positioned relative to it: horizontal marks sit just below the
    # track (top-full), vertical marks sit beside it (left-full, inset-y-0).
    # Pass marks: (Array of Hashes {value:, label:} or bare integers) and
    # orientation: (:horizontal/:vertical, default :horizontal) to enable.
    class SliderControl < Wabi::Base
      def initialize(orientation: :horizontal, marks: [], **attrs)
        @vertical = orientation.to_sym == :vertical
        @marks    = Array(marks).map { |m| m.is_a?(Hash) ? m : { value: m, label: nil } }
        @attrs    = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)

        # Base control classes — built from @vertical so we know orientation at
        # SSR without relying on data-[orientation=vertical]: CSS variants.
        base  = "relative flex w-full items-center"
        base += " h-full flex-col" if @vertical

        # Reserve space for the absolutely-positioned marker group so it doesn't
        # overlap content outside the control.
        if @marks.any?
          base += @vertical ? " mr-12" : " mb-8"
        end

        div(
          data: { "wabi--slider-target": "control" },
          class: merge_class(base, user_class)
        ) do
          yield if block_given?

          if @marks.any?
            # Zag's getMarkerGroupProps spreads `position:relative` inline, which
            # would override an `absolute` Tailwind class and collapse the group to
            # zero size. To keep our absolute-positioning intact we wrap the Zag
            # target in an outer div that does the absolute placement, then let the
            # inner Zag target be `relative w-full h-full` so it fills the wrapper.
            outer_class  = @vertical \
              ? "absolute left-full inset-y-0 ml-2 pointer-events-none" \
              : "absolute top-full left-0 w-full mt-1 pointer-events-none"
            inner_class  = "relative w-full h-full"
            marker_class = @vertical \
              ? "absolute flex items-center" \
              : "absolute flex flex-col items-center"
            tick_class   = @vertical \
              ? "block h-0.5 w-2 rounded-full bg-muted-foreground" \
              : "block h-2 w-0.5 rounded-full bg-muted-foreground"
            label_class  = @vertical \
              ? "ml-2 block text-xs text-muted-foreground whitespace-nowrap" \
              : "mt-1 block text-xs text-muted-foreground whitespace-nowrap"

            div(class: outer_class) do
              div(data: { "wabi--slider-target": "markerGroup" }, class: inner_class) do
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
      end
    end
  end
end
