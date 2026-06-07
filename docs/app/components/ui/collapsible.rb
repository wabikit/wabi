# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class Collapsible < Wabi::Base
      def initialize(id: nil, open: false, disabled: false, **attrs)
        @id       = id
        @open     = open
        @disabled = disabled
        @attrs    = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          id: @id,
          data: {
            controller: "wabi--collapsible",
            "wabi--collapsible-open-value":     @open.to_s,
            "wabi--collapsible-disabled-value": @disabled.to_s,
          },
          class: merge_class("w-full", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
