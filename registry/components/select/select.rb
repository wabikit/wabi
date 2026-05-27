# frozen_string_literal: true

require "json"
require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class Select < Wabi::Base
      def initialize(id: nil, name: nil, value: nil, disabled: false, items: [], placeholder: "Select an option", portal: true, **attrs)
        @id          = id
        @name        = name
        @value       = value
        @disabled    = disabled
        @items       = items
        @placeholder = placeholder
        @portal      = portal
        @attrs       = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          id: @id,
          data: {
            controller: "wabi--select",
            "wabi--select-items-value":       @items.to_json,
            "wabi--select-name-value":        @name,
            "wabi--select-value-value":       @value,
            "wabi--select-disabled-value":    @disabled.to_s,
            "wabi--select-placeholder-value": @placeholder,
            "wabi--select-portal-value":      @portal.to_s,
          },
          class: merge_class("relative inline-block", user_class)
        ) do
          # Real <select> kept visually hidden for form submission and a11y.
          # Zag's getHiddenSelectProps fills in the <option> set at hydration.
          select(
            name: @name,
            disabled: @disabled,
            data: { "wabi--select-target": "hiddenSelect" },
            class: "sr-only",
            tabindex: "-1",
            "aria-hidden": "true"
          )
          yield if block_given?
        end
      end
    end
  end
end
