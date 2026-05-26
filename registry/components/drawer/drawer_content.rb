# frozen_string_literal: true

require "date"

module Components
  module UI
    class DrawerContent < Wabi::Base
      # Side-anchored positioning. Right/left occupy a vertical strip; top/bottom
      # a horizontal strip. The visible content slot is `pointer-events-auto`
      # while the surrounding (empty) area is non-interactive so clicks pass
      # through to the backdrop dismiss handler. v0.1 ships without slide-in /
      # slide-out animations -- `hidden: !open` toggling via Zag would interrupt
      # any CSS transition. Animation polish is a v0.2 task.
      SIDE_CLASSES = {
        top:    "fixed inset-x-0 top-0    w-full max-h-screen border-input",
        right:  "fixed inset-y-0 right-0  h-full w-3/4 sm:max-w-sm border-input",
        bottom: "fixed inset-x-0 bottom-0 w-full max-h-screen border-input",
        left:   "fixed inset-y-0 left-0   h-full w-3/4 sm:max-w-sm border-input",
      }.freeze

      BASE = "z-50 grid gap-4 bg-background p-6 shadow-lg"

      BACKDROP_CLASS = "fixed inset-0 z-40 bg-black/80 " \
                       "transition-opacity duration-200 " \
                       "data-[state=open]:opacity-100 data-[state=closed]:opacity-0"

      def initialize(side: :right, **attrs)
        @side  = side
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        # No positioner wrapper for Drawer -- content uses its own fixed
        # positioning per side. The portal stays in the controller scope
        # (no body.appendChild) so Stimulus targets keep resolving. Same
        # caveats as Dialog regarding portal-move and Stimulus target
        # tracking; see `zag-js-pattern` memory note #9.
        div(data: { "wabi--dialog-target": "portal" }) do
          div(
            data: { "wabi--dialog-target": "backdrop" },
            hidden: true,
            class: BACKDROP_CLASS
          )
          div(
            role: "dialog",
            "aria-modal": "true",
            data: { "wabi--dialog-target": "content" },
            hidden: true,
            class: merge_class(BASE, SIDE_CLASSES.fetch(@side), user_class)
          ) do
            yield if block_given?
          end
        end
      end
    end
  end
end
