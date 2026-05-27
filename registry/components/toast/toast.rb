# frozen_string_literal: true

require "date"

module Components
  module UI
    # Static / SSR Toast. Renders an `<li>` with no controller — the parent
    # Toaster's group machine adopts visible toasts on connect. Use this for
    # initial-page-load flashes that need to show before JS hydration; for
    # programmatic creation, prefer `turbo_stream.wabi_toast(...)` (which
    # emits a `wabi_toast_create` action picked up by the Toaster
    # controller) or `window.wabiToaster.create({...})`.
    class Toast < Wabi::Base
      variants do
        base "pointer-events-auto w-full overflow-hidden rounded-md border border-input p-4 shadow-md"

        variant :appearance, {
          info:        "bg-background text-foreground",
          success:     "bg-primary text-primary-foreground",
          destructive: "bg-destructive text-destructive-foreground",
        }, default: :info
      end

      def initialize(title:, description: nil, appearance: nil, **attrs)
        @title       = title
        @description = description
        @appearance  = appearance
        @attrs       = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        li(
          role: (@appearance == :destructive ? "alert" : "status"),
          "aria-live": (@appearance == :destructive ? "assertive" : "polite"),
          "aria-atomic": "true",
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
              class: "shrink-0 rounded-md p-1 text-current opacity-70 hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring"
            ) { "×" }
          end
        end
      end
    end
  end
end
