# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class CommandDialog < Wabi::Base
      DIALOG_CLASS = "fixed left-1/2 top-1/4 z-50 grid w-full max-w-2xl -translate-x-1/2 " \
                     "gap-0 border border-input bg-background shadow-lg sm:rounded-lg " \
                     "overflow-hidden " \
                     "transition-opacity duration-200 ease-out " \
                     "data-[state=open]:opacity-100 data-[state=open]:pointer-events-auto " \
                     "data-[state=closed]:opacity-0 data-[state=closed]:pointer-events-none"

      BACKDROP_CLASS = "fixed inset-0 z-40 bg-black/80 " \
                       "transition-opacity duration-200 ease-out " \
                       "data-[state=open]:opacity-100 data-[state=open]:pointer-events-auto " \
                       "data-[state=closed]:opacity-0 data-[state=closed]:pointer-events-none"

      POSITIONER_CLASS = "fixed inset-0 z-50 pointer-events-none"

      def initialize(label: "Command palette", **attrs)
        @label = label
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        # No outer portal-target wrapper: wabi--dialog#attachToBody moves the
        # positioner (and backdrop) directly to <body>. The wrapper was a
        # vestigial placeholder and now that "portal" is gone from the
        # controller's static targets it would only trigger a Stimulus
        # "Missing target" warning.
        div(
          data: { "wabi--dialog-target": "backdrop" },
          "data-state": "closed",
          class: BACKDROP_CLASS
        )
        div(
          data: { "wabi--dialog-target": "positioner" },
          class: POSITIONER_CLASS
        ) do
          # Dialog content owns role/aria-modal/data-state. The combobox
          # controller must NOT mount on this element directly — its
          # spreadProps(getRootProps()) would strip data-state and break
          # the data-[state=closed]:opacity-0 fade. Mount it on an inner
          # wrapper instead so both controllers manage their own elements.
          div(
            **@attrs,
            role: "dialog",
            "aria-modal": "true",
            "data-state": "closed",
            inert: true,
            data: { "wabi--dialog-target": "content" },
            class: merge_class(DIALOG_CLASS, user_class)
          ) do
            # Visually-hidden title gives the role=dialog an accessible name:
            # wabi--dialog spreads getTitleProps() (with an id) onto this target
            # and Zag injects aria-labelledby on the content at runtime.
            span(
              data: { "wabi--dialog-target": "title" },
              class: "sr-only"
            ) { @label }
            div(
              data: {
                controller: "wabi--combobox",
                "wabi--combobox-portal-value": "false",
                "wabi--combobox-items-value": "[]",
              }
            ) do
              yield if block_given?
            end
          end
        end
      end
    end
  end
end
