# frozen_string_literal: true

require "json"
require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class ToggleGroup < Wabi::Base
      def initialize(type: :single, value: nil, name: nil, disabled: false, **attrs)
        @type     = type
        @value    = Array(value).compact
        @name     = name
        @disabled = disabled
        @attrs    = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          **@attrs,
          role: "group",
          data: {
            controller: "wabi--toggle-group",
            "wabi--toggle-group-multiple-value": (@type == :multiple).to_s,
            "wabi--toggle-group-value-value":    @value.to_json,
            "wabi--toggle-group-name-value":     @name,
            "wabi--toggle-group-disabled-value": @disabled.to_s,
          },
          class: merge_class("inline-flex items-center gap-1 rounded-md", user_class),
          &block
        )
      end
    end
  end
end
