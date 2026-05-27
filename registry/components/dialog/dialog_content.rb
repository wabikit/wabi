# frozen_string_literal: true

require "date"

module Components
  module UI
    class DialogContent < Wabi::Base
      variants do
        # `data-[state=closed]:pointer-events-none` is critical: when closed,
        # the content is `opacity-0` (invisible) but STILL `fixed` with a
        # centered footprint. Without disabling pointer events when closed,
        # the invisible box intercepts clicks in the center of the viewport.
        # Same trap as the original positioner-covers-everything bug.
        base "fixed left-1/2 top-1/2 z-50 grid w-full max-w-lg -translate-x-1/2 -translate-y-1/2 " \
             "gap-4 border border-input bg-background p-6 shadow-lg sm:rounded-lg " \
             "transition-opacity duration-200 ease-out " \
             "data-[state=open]:opacity-100 data-[state=open]:pointer-events-auto " \
             "data-[state=closed]:opacity-0 data-[state=closed]:pointer-events-none"
      end

      # Backdrop also needs the pointer-events flip -- it's `fixed inset-0`
      # which covers the entire viewport even at opacity 0.
      BACKDROP_CLASS = "fixed inset-0 z-40 bg-black/80 " \
                       "transition-opacity duration-200 ease-out " \
                       "data-[state=open]:opacity-100 data-[state=open]:pointer-events-auto " \
                       "data-[state=closed]:opacity-0 data-[state=closed]:pointer-events-none"

      POSITIONER_CLASS = "fixed inset-0 z-50 flex items-center justify-center pointer-events-none"

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        # Visibility now lives on `data-state` rather than the `hidden`
        # attribute. The controller force-clears `hidden` after spreadProps
        # (Zag still sets it from getContentProps/getBackdropProps) and
        # applies `inert` on the content when closed so tab order skips it.
        # Without that switch, `hidden` cascades display:none and CSS
        # transitions never run (the element snaps off-screen mid-fade).
        div(data: { "wabi--dialog-target": "portal" }) do
          div(
            data: { "wabi--dialog-target": "backdrop" },
            "data-state": "closed",
            class: BACKDROP_CLASS
          )
          div(
            data: { "wabi--dialog-target": "positioner" },
            class: POSITIONER_CLASS
          ) do
            div(
              role: "dialog",
              "aria-modal": "true",
              "data-state": "closed",
              data: { "wabi--dialog-target": "content" },
              inert: true,
              class: merge_class(tokens, user_class)
            ) do
              yield if block_given?
            end
          end
        end
      end
    end
  end
end
