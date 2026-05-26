# frozen_string_literal: true

require "date"
require "json"

module Components
  module UI
    class Accordion < Wabi::Base
      def initialize(type: :single, value: [], collapsible: true, id: nil, **attrs)
        @id          = id
        @type        = type
        @value       = Array(value)
        @collapsible = collapsible
        @attrs       = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          id: @id,
          data: {
            controller: "wabi--accordion",
            "wabi--accordion-multiple-value":    (@type == :multiple).to_s,
            "wabi--accordion-value-value":       @value.to_json,
            "wabi--accordion-collapsible-value": @collapsible.to_s,
          },
          class: user_class
        ) do
          yield if block_given?
        end
      end
    end
  end
end
