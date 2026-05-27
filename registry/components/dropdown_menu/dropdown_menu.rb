# frozen_string_literal: true

require "date"

module Components
  module UI
    class DropdownMenu < Wabi::Base
      def initialize(id: nil, open: false, portal: true, **attrs)
        @id     = id
        @open   = open
        @portal = portal
        @attrs  = attrs
      end

      def view_template(&block)
        div(
          id: @id,
          class: "inline-block",
          data: {
            controller: "wabi--dropdown-menu",
            "wabi--dropdown-menu-open-value":   @open.to_s,
            "wabi--dropdown-menu-portal-value": @portal.to_s,
          }
        ) do
          yield if block_given?
        end
      end
    end
  end
end
