# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class Checkbox < Wabi::Base
      variants do
        base "peer h-4 w-4 shrink-0 rounded-sm border border-primary " \
             "ring-offset-background focus-visible:outline-none focus-visible:ring-2 " \
             "focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed " \
             "disabled:opacity-50 data-[state=checked]:bg-primary data-[state=checked]:text-primary-foreground"
      end

      def initialize(name: nil, value: "1", checked: false, disabled: false, **attrs)
        @name     = name
        @value    = value
        @checked  = checked
        @disabled = disabled
        @attrs    = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        div(
          data: {
            controller: "wabi--checkbox",
            "wabi--checkbox-checked-value": @checked,
            "wabi--checkbox-disabled-value": @disabled,
          },
          class: "inline-flex items-center"
        ) do
          button(
            type: "button",
            role: "checkbox",
            "aria-checked": @checked.to_s,
            "data-state": @checked ? "checked" : "unchecked",
            disabled: @disabled,
            data: { "wabi--checkbox-target": "root" },
            class: merge_class(tokens, user_class)
          ) do
            span(data: { "wabi--checkbox-target": "indicator" }) do
              # rendered when checked — heroicons "check" inline SVG
              raw(safe('<svg class="h-3 w-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>'))
            end
          end
          # Hidden input mirrors the state for form submission
          input(type: "hidden", name: @name, value: (@checked ? @value : nil),
                data: { "wabi--checkbox-target": "hiddenInput" })
        end
      end
    end
  end
end
