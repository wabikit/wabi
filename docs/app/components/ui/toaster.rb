# frozen_string_literal: true

require "date"

module Components
  module UI
    # Singleton container for toasts. Render ONCE near the end of <body> in your
    # layout. Toasts are appended to this <ol> -- typically via Turbo Stream:
    #
    #   turbo_stream.append "wabi-toaster",
    #     Components::UI::Toast.new(title: "Saved", appearance: :success)
    #
    # The list is `pointer-events-none` so the empty toaster doesn't block clicks
    # behind it; individual toasts override with `pointer-events-auto`.
    class Toaster < Wabi::Base
      def initialize(id: "wabi-toaster", placement: :top_right, **attrs)
        @id        = id
        @placement = placement
        @attrs     = attrs
      end

      PLACEMENT_CLASSES = {
        top_left:      "top-4 left-4 items-start",
        top_center:    "top-4 left-1/2 -translate-x-1/2 items-center",
        top_right:     "top-4 right-4 items-end",
        bottom_left:   "bottom-4 left-4 items-start",
        bottom_center: "bottom-4 left-1/2 -translate-x-1/2 items-center",
        bottom_right:  "bottom-4 right-4 items-end",
      }.freeze

      def view_template
        user_class = @attrs.delete(:class)
        # `w-96` + `h-fit` keeps the <ol> sized to its actual toast content even
        # before any toasts are appended -- without an explicit width, an empty
        # flex-col container can collapse to 0 OR expand under certain Tailwind
        # 4 layout rules. `z-50` (built-in) replaces the earlier `z-[100]`
        # arbitrary value to avoid any class-emit ambiguity.
        ol(
          id: @id,
          role: "region",
          "aria-label": "Notifications",
          class: merge_class(
            "fixed z-50 flex flex-col gap-2 w-96 max-w-[calc(100vw-2rem)] h-fit pointer-events-none list-none p-0 m-0",
            PLACEMENT_CLASSES.fetch(@placement),
            user_class,
          )
        )
      end
    end
  end
end
