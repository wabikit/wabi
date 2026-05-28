# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class ComboboxTrigger < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          type: "button",
          data: { "wabi--combobox-target": "trigger" },
          class: merge_class(
            "absolute right-2 top-1/2 -translate-y-1/2 h-6 w-6 " \
            "flex items-center justify-center opacity-50 hover:opacity-100",
            user_class
          )
        ) do
          if block_given?
            yield
          else
            # Default chevron-down SVG icon (inline)
            raw safe(<<~SVG)
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
                fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
            SVG
          end
        end
      end
    end
  end
end
