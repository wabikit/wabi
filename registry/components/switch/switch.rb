# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class Switch < Wabi::Base
      variants do
        base "peer inline-flex h-6 w-11 shrink-0 cursor-pointer items-center rounded-full " \
             "border-2 border-transparent transition-colors focus-visible:outline-none " \
             "focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 " \
             "focus-visible:ring-offset-background disabled:cursor-not-allowed disabled:opacity-50 " \
             "data-[state=checked]:bg-primary data-[state=unchecked]:bg-input"
      end

      THUMB_CLASS = "pointer-events-none block h-5 w-5 rounded-full bg-background shadow-lg " \
                    "ring-0 transition-transform data-[state=checked]:translate-x-5 " \
                    "data-[state=unchecked]:translate-x-0"

      def initialize(name: nil, checked: false, disabled: false, **attrs)
        @name     = name
        @checked  = checked
        @disabled = disabled
        @attrs    = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        div(
          data: {
            controller: "wabi--switch",
            "wabi--switch-checked-value": @checked,
            "wabi--switch-disabled-value": @disabled,
          },
          class: "inline-flex items-center"
        ) do
          button(
            type: "button",
            role: "switch",
            "aria-checked": @checked.to_s,
            "data-state": @checked ? "checked" : "unchecked",
            disabled: @disabled,
            data: { "wabi--switch-target": "root" },
            class: merge_class(tokens, user_class)
          ) do
            span(
              "data-state": @checked ? "checked" : "unchecked",
              data: { "wabi--switch-target": "thumb" },
              class: THUMB_CLASS
            )
          end
          input(type: "hidden", name: @name, value: (@checked ? "1" : "0"),
                data: { "wabi--switch-target": "hiddenInput" })
        end
      end
    end
  end
end
