# frozen_string_literal: true

require "date"

module Components
  module UI
    class SelectValue < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        span(
          data: { "wabi--select-target": "valueText" },
          class: merge_class("pointer-events-none truncate", user_class)
        )
      end
    end
  end
end
