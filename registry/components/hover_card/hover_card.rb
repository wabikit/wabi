# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class HoverCard < Wabi::Base
      def initialize(id: nil, open_delay: 700, close_delay: 300, portal: true, **attrs)
        @id          = id
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
            controller: "wabi--hover-card",
            "wabi--hover-card-open-delay-value":  @open_delay.to_s,
            "wabi--hover-card-close-delay-value": @close_delay.to_s,
            "wabi--hover-card-portal-value":      @portal.to_s,
          }
        ) do
          yield if block_given?
        end
      end
    end
  end
end
