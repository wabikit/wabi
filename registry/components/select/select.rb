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
          # Zag's getHiddenSelectProps only sets attributes, so we render the
          # <option> set ourselves (mirroring @items); the controller's render()
          # then syncs the selected value for form submission.
          select(
            name: @name,
            disabled: @disabled,
            data: { "wabi--select-target": "hiddenSelect" },
            class: "sr-only",
            tabindex: "-1",
            "aria-hidden": "true"
          ) do
            # Leading empty option: with no selection the form submits "" rather
            # than the native default (the first <option>).
            option(value: "", selected: @value.nil? || @value == "") { @placeholder }
            @items.each do |item|
              item = item.transform_keys(&:to_sym) if item.is_a?(Hash)
              option(value: item[:value], selected: item[:value].to_s == @value.to_s) { item[:label] }
            end
          end
          yield if block_given?
        end
      end
    end
  end
end
