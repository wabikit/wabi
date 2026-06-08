# frozen_string_literal: true

require "date"

module Components
  module UI
    # A single notification. Render via Turbo Stream into the Toaster container,
    # or inline in a Phlex view for static / story examples. Has its own
    # `wabi--toast` Stimulus controller that handles auto-dismiss with
    # pause-on-hover -- v0.1 skips Zag's `@zag-js/toast` group machinery in
    # favor of a self-contained vanilla timer. Cross-toast coordination (max
    # visible, advanced stacking) is a v0.2 follow-up.
    class Toast < Wabi::Base
      variants do
        base "pointer-events-auto w-full overflow-hidden rounded-md border border-input p-4 shadow-md " \
             "transition-all duration-300 ease-out motion-reduce:transition-none motion-reduce:opacity-100 " \
             "data-[state=open]:opacity-100 data-[state=closed]:opacity-0"

        variant :appearance, {
          info:        "bg-background text-foreground",
          success:     "bg-primary text-primary-foreground",
          destructive: "bg-destructive text-destructive-foreground",
        }, default: :info
      end

      def initialize(title:, description: nil, appearance: nil, duration_ms: 5000, **attrs)
        @title       = title
        @description = description
        @appearance  = appearance
        @duration_ms = duration_ms
        @attrs       = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        # No per-<li> live-region attrs: announcement comes from the Toaster <ol>
        # (the pre-existing aria-live region) when this <li> is appended into it.
        li(
          "data-state": "open",
          data: {
            controller: "wabi--toast",
            "wabi--toast-duration-ms-value": @duration_ms.to_s,
          },
          class: merge_class(tokens(appearance: @appearance), user_class)
        ) do
          div(class: "flex items-start justify-between gap-3") do
            div(class: "grid gap-1") do
              div(class: "text-sm font-semibold") { @title }
              div(class: "text-sm opacity-90") { @description } if @description
            end
            button(
              type: "button",
              "aria-label": "Dismiss",
              data: { action: "click->wabi--toast#dismiss" },
              class: "shrink-0 rounded-md p-1 text-current opacity-70 hover:opacity-100 focus-visible:opacity-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
            ) { "×" }
          end
        end
      end
    end
  end
end
