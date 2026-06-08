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
      def initialize(id: "wabi-toaster", placement: :top_right, visible_count: 3, gap: 14, **attrs)
        @id            = id
        @placement     = placement
        @visible_count = visible_count
        @gap           = gap
        @attrs         = attrs
      end

      PLACEMENT_CLASSES = {
        top_left:      "top-4 left-4",
        top_center:    "top-4 left-1/2 -translate-x-1/2",
        top_right:     "top-4 right-4",
        bottom_left:   "bottom-4 left-4",
        bottom_center: "bottom-4 left-1/2 -translate-x-1/2",
        bottom_right:  "bottom-4 right-4",
      }.freeze

      def view_template
        user_class = @attrs.delete(:class)
        # The <ol> is the containing block for its absolutely-positioned toast
        # <li> children: the wabi--toaster controller sets each toast to
        # position:absolute and assigns its translateY/scale transform. Without
        # JS the <li>s fall back to normal block flow (a plain vertical list),
        # so the no-JS experience still works. `w-96`/`h-fit` keep the empty
        # container sized correctly; `position: fixed` is itself the containing
        # block for the absolute toast children.
        ol(
          id: @id,
          role: "region",
          "aria-label": "Notifications",
          # The <ol> is the live region: it pre-exists, so toast <li>s appended
          # via Turbo Stream are announced. (Per-<li> live-region attrs do NOT
          # announce — AT only reacts to mutations inside an existing live region.)
          "aria-live": "polite",
          "aria-atomic": "false",
          data: {
            controller: "wabi--toaster",
            # @id must be a simple alphanumeric/hyphen string; no CSS escaping is applied.
            "wabi--toaster-wabi--toast-outlet": "##{@id} > [data-controller~='wabi--toast']",
            "wabi--toaster-placement-value": @placement.to_s,
            "wabi--toaster-visible-count-value": @visible_count.to_s,
            "wabi--toaster-gap-value": @gap.to_s,
          },
          class: merge_class(
            "fixed z-50 w-96 max-w-[calc(100vw-2rem)] h-fit pointer-events-none list-none p-0 m-0",
            PLACEMENT_CLASSES.fetch(@placement),
            user_class,
          )
        )
      end
    end
  end
end
