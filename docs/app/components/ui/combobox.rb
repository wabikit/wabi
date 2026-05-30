# frozen_string_literal: true

require "json"
require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class Combobox < Wabi::Base
      def initialize(name:, items:, value: nil, placeholder: "Select an option...", disabled: false, portal: true, url: nil, param: "q", debounce: 250, min_length: 1, **attrs)
        @name        = name
        @items       = items
        @value       = value
        @placeholder = placeholder
        @disabled    = disabled
        @portal      = portal
        @url         = url
        @param       = param
        @debounce    = debounce
        @min_length  = min_length
        @attrs       = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        data = {
          controller: "wabi--combobox",
          "wabi--combobox-name-value":        @name,
          "wabi--combobox-items-value":       @items.to_json,
          "wabi--combobox-value-value":       @value,
          "wabi--combobox-placeholder-value": @placeholder,
          "wabi--combobox-disabled-value":    @disabled.to_s,
          "wabi--combobox-portal-value":      @portal.to_s,
        }
        # Async keys emitted only when a URL is given (sync mode stays
        # byte-identical). Symbol keys to match the base hash above.
        # NOTE: these defaults (param "q", debounce 250, min_length 1) mirror
        # the controller's static-value defaults — keep the two in sync.
        if @url
          data[:"wabi--combobox-url-value"]        = @url
          data[:"wabi--combobox-param-value"]      = @param
          data[:"wabi--combobox-debounce-value"]   = @debounce.to_s
          data[:"wabi--combobox-min-length-value"] = @min_length.to_s
        end
        div(
          **@attrs,
          data: data,
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
