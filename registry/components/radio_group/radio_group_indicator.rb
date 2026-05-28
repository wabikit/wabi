# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class RadioGroupIndicator < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        span(
          data: { "wabi--radio-group-target": "itemIndicator" },
          "data-state": "unchecked",
          class: merge_class(
            "h-2.5 w-2.5 rounded-full bg-primary " \
            "data-[state=checked]:opacity-100 data-[state=unchecked]:opacity-0 " \
            "transition-opacity",
            user_class
          )
        )
      end
    end
  end
end
