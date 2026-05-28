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

      def initialize(**attrs)
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
            data: { "wabi--dialog-target": "positioner" },
            class: POSITIONER_CLASS
          ) do
            div(
              **@attrs,
              role: "dialog",
              "aria-modal": "true",
              "data-state": "closed",
              inert: true,
              data: {
                "wabi--dialog-target": "content",
                controller: "wabi--combobox",
                "wabi--combobox-portal-value": "false",
                "wabi--combobox-items-value": "[]",
              },
              class: merge_class(DIALOG_CLASS, user_class)
            ) do
              yield if block_given?
            end
          end
        end
      end
    end
  end
end
