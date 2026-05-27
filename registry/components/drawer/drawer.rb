# frozen_string_literal: true

require "date"

module Components
  module UI
    class Drawer < Wabi::Base
      def initialize(id: nil, open: false, side: :right, portal: true, **attrs)
        @id     = id
        @open   = open
        @side   = side
        @portal = portal
        @attrs  = attrs
      end

      def view_template(&block)
        div(
          id: @id,
          data: {
            controller: "wabi--dialog",
            "wabi--dialog-open-value":   @open.to_s,
            "wabi--dialog-modal-value":  "true",
            "wabi--dialog-portal-value": @portal.to_s,
            "wabi-side": @side.to_s,
          }
        ) do
          yield if block_given?
        end
      end
    end
  end
end
