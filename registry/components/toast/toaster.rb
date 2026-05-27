# frozen_string_literal: true

require "date"

module Components
  module UI
    # Group-machine Toaster. ONE Toaster per page by default; multiple
    # placements are achieved by adding additional Toaster instances with
    # distinct IDs. The Toaster hosts a single `@zag-js/toast` group
    # machine; toasts are created via `turbo_stream.wabi_toast(...)` (which
    # emits a `wabi_toast_create` custom Turbo Stream action) or directly
    # in JS via `window.wabiToaster.create({title, description, type})`.
    class Toaster < Wabi::Base
      DEFAULT_PLACEMENT = "bottom-end"

      def initialize(
        id: "wabi-toaster",
        placement: DEFAULT_PLACEMENT,
        max: 5,
        gap: 16,
        duration: 5000,
        swipe_direction: "right",
        **attrs
      )
        @id        = id
        @placement = placement
        @max       = max
        @gap       = gap
        @duration  = duration
        @swipe_dir = swipe_direction
        @attrs     = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        ol(
          id: @id,
          role: "region",
          "aria-label": "Notifications",
          data: {
            controller: "wabi--toast",
            "wabi--toast-max-value":             @max.to_s,
            "wabi--toast-gap-value":             @gap.to_s,
            "wabi--toast-placement-value":       @placement,
            "wabi--toast-duration-value":        @duration.to_s,
            "wabi--toast-swipe-direction-value": @swipe_dir,
          },
          class: merge_class(
            "fixed z-50 flex flex-col gap-2 w-96 max-w-[calc(100vw-2rem)] h-fit pointer-events-none list-none p-0 m-0",
            user_class,
          )
        ) do
          template(data: { "wabi--toast-target": "template" }) do
            li(
              role: "status",
              "aria-live": "polite",
              "aria-atomic": "true",
              class: "pointer-events-auto w-full overflow-hidden rounded-md " \
                     "border border-input bg-background text-foreground p-4 shadow-md"
            ) do
              div(class: "flex items-start justify-between gap-3") do
                div(class: "grid gap-1") do
                  div(class: "text-sm font-semibold", data: { slot: "title" })
                  div(class: "text-sm opacity-90",   data: { slot: "description" })
                end
                button(
                  type: "button",
                  "aria-label": "Dismiss",
                  data: { slot: "close" },
                  class: "shrink-0 rounded-md p-1 text-current opacity-70 hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring"
                ) { "×" }
              end
            end
          end
        end
      end
    end
  end
end
