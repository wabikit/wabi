# frozen_string_literal: true

require "date"

module Components
  module UI
    class DrawerContent < Wabi::Base
      # Side-anchored positioning + slide-in/out transform per side. Each side
      # has its own "off-screen" translate when closed; opening returns to
      # `translate-0`. v0.1.x: visibility lives on `data-state` rather than
      # `hidden`, so the slide actually animates.
      SIDE_CLASSES = {
        top: "fixed inset-x-0 top-0 w-full max-h-screen border-input " \
             "data-[state=open]:translate-y-0 data-[state=closed]:-translate-y-full",
        right: "fixed inset-y-0 right-0 h-full w-3/4 sm:max-w-sm border-input " \
               "data-[state=open]:translate-x-0 data-[state=closed]:translate-x-full",
        bottom: "fixed inset-x-0 bottom-0 w-full max-h-screen border-input " \
                "data-[state=open]:translate-y-0 data-[state=closed]:translate-y-full",
        left: "fixed inset-y-0 left-0 h-full w-3/4 sm:max-w-sm border-input " \
              "data-[state=open]:translate-x-0 data-[state=closed]:-translate-x-full",
      }.freeze

      # `data-[state=closed]:pointer-events-none` keeps the off-screen drawer
      # from intercepting clicks at its side strip when closed (e.g. a right
      # drawer translated 100% off-screen still has its bounding box at the
      # right edge until pointer-events-none is applied).
      BASE = "z-50 grid gap-4 bg-background p-6 shadow-lg " \
             "transition-transform duration-300 ease-out " \
             "data-[state=open]:pointer-events-auto data-[state=closed]:pointer-events-none"

      BACKDROP_CLASS = "fixed inset-0 z-40 bg-black/80 " \
                       "transition-opacity duration-200 ease-out " \
                       "data-[state=open]:opacity-100 data-[state=open]:pointer-events-auto " \
                       "data-[state=closed]:opacity-0 data-[state=closed]:pointer-events-none"

      def initialize(side: :right, **attrs)
        @side  = side
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(data: { "wabi--dialog-target": "portal" }) do
          div(
            data: { "wabi--dialog-target": "backdrop" },
            "data-state": "closed",
            class: BACKDROP_CLASS
          )
          div(
            role: "dialog",
            "aria-modal": "true",
            "data-state": "closed",
            data: { "wabi--dialog-target": "content" },
            class: merge_class(BASE, SIDE_CLASSES.fetch(@side), user_class)
          ) do
            yield if block_given?
          end
        end
      end
    end
  end
end
