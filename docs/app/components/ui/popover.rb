# frozen_string_literal: true

require "date"

module Components
  module UI
    class Popover < Wabi::Base
      def initialize(id: nil, open: false, modal: false, portal: true, **attrs)
        @id     = id
        @open   = open
        @modal  = modal
        @portal = portal
        @attrs  = attrs
      end

      def view_template(&block)
        div(
          id: @id,
          class: "inline-block",
          data: {
            controller: "wabi--popover",
            "wabi--popover-open-value":   @open.to_s,
            "wabi--popover-modal-value":  @modal.to_s,
            "wabi--popover-portal-value": @portal.to_s,
          }
        ) do
          yield if block_given?
        end
      end
    end
  end
end
