# frozen_string_literal: true

require "date"

module Components
  module UI
    class ContextMenu < Wabi::Base
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
            controller: "wabi--context-menu",
            "wabi--context-menu-open-value":   @open.to_s,
            "wabi--context-menu-portal-value": @portal.to_s,
          }
        ) do
          yield if block_given?
        end
      end
    end
  end
end
