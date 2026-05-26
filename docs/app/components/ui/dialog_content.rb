# frozen_string_literal: true

require "date"

module Components
  module UI
    class DialogContent < Wabi::Base
      variants do
        base "fixed left-1/2 top-1/2 z-50 grid w-full max-w-lg -translate-x-1/2 -translate-y-1/2 " \
             "gap-4 border-input bg-background p-6 shadow-lg sm:rounded-lg " \
             "transition-opacity duration-200 " \
             "data-[state=open]:opacity-100 data-[state=closed]:opacity-0"
      end

      BACKDROP_CLASS = "fixed inset-0 z-40 bg-black/80 " \
                       "transition-opacity duration-200 " \
                       "data-[state=open]:opacity-100 data-[state=closed]:opacity-0"

      # `pointer-events-none` so the wrapper never intercepts clicks on the page
      # below when the dialog is closed -- without this AND the `hidden` toggle
      # the fixed-inset-0 z-50 layer captures every click on the document.
      POSITIONER_CLASS = "fixed inset-0 z-50 flex items-center justify-center pointer-events-none"

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        # Portal wrapper has NO `hidden` -- children (backdrop, content) carry
        # their own `hidden: !open` from Zag. A hidden portal would cascade
        # display:none over the whole tree and the dialog could never show.
        # The controller moves this subtree into <body> on connect().
        div(data: { "wabi--dialog-target": "portal" }) do
          div(
            data: { "wabi--dialog-target": "backdrop" },
            hidden: true,
            class: BACKDROP_CLASS
          )
          div(
            data: { "wabi--dialog-target": "positioner" },
            hidden: true,
            class: POSITIONER_CLASS
          ) do
            div(
              role: "dialog",
              "aria-modal": "true",
              data: { "wabi--dialog-target": "content" },
              hidden: true,
              class: merge_class("pointer-events-auto", tokens, user_class)
            ) do
              yield if block_given?
            end
          end
        end
      end
    end
  end
end
