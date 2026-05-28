# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class ComboboxItemIndicator < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        span(
          data: { "wabi--combobox-target": "itemIndicator" },
          class: merge_class("absolute right-2 flex h-3.5 w-3.5 items-center justify-center", user_class)
        )
      end
    end
  end
end
