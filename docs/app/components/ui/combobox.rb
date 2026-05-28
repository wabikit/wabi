# frozen_string_literal: true

require "json"
require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class Combobox < Wabi::Base
      def initialize(name:, items:, value: nil, placeholder: "Select an option...", disabled: false, portal: true, **attrs)
        @name        = name
        @items       = items
        @value       = value
        @placeholder = placeholder
        @disabled    = disabled
        @portal      = portal
        @attrs       = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          **@attrs,
          data: {
            controller: "wabi--combobox",
            "wabi--combobox-name-value":        @name,
            "wabi--combobox-items-value":       @items.to_json,
            "wabi--combobox-value-value":       @value,
            "wabi--combobox-placeholder-value": @placeholder,
            "wabi--combobox-disabled-value":    @disabled.to_s,
            "wabi--combobox-portal-value":      @portal.to_s,
          },
          class: merge_class("relative", user_class)
        ) do
          # Hidden input mirrors the selected VALUE for form submission. The
          # visible <input> carries the label; without this Rails forms would
          # receive "Ruby on Rails" instead of "rails".
          input(
            type: "hidden",
            name: @name,
            value: @value,
            data: { "wabi--combobox-target": "hiddenInput" }
          )
          yield if block_given?
        end
      end
    end
  end
end
