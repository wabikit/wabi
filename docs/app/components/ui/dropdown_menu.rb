# frozen_string_literal: true

require "date"

module Components
  module UI
    class DropdownMenu < Wabi::Base
      def initialize(id: nil, open: false, **attrs)
        @id    = id
        @open  = open
        @attrs = attrs
      end

      def view_template(&block)
        div(
          id: @id,
          class: "inline-block",
          data: {
            controller: "wabi--dropdown-menu",
            "wabi--dropdown-menu-open-value": @open.to_s,
          }
        ) do
          yield if block_given?
        end
      end
    end
  end
end
