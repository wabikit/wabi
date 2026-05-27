# frozen_string_literal: true

require "date"

module Components
  module UI
    class Tooltip < Wabi::Base
      def initialize(id: nil, open: false, open_delay: 700, close_delay: 300, portal: true, **attrs)
        @id          = id
        @open        = open
        @open_delay  = open_delay
        @close_delay = close_delay
        @portal      = portal
        @attrs       = attrs
      end

      def view_template(&block)
        div(
          id: @id,
          class: "inline-block",
          data: {
            controller: "wabi--tooltip",
            "wabi--tooltip-open-value":        @open.to_s,
            "wabi--tooltip-open-delay-value":  @open_delay.to_s,
            "wabi--tooltip-close-delay-value": @close_delay.to_s,
            "wabi--tooltip-portal-value":      @portal.to_s,
          }
        ) do
          yield if block_given?
        end
      end
    end
  end
end
