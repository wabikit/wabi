# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class NavigationMenuTrigger < Wabi::Base
      def initialize(value:, **attrs)
        @value = value
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          type: "button",
          data: { "wabi--navigation-menu-target": "trigger", "wabi-value": @value.to_s },
          class: merge_class(
            "inline-flex items-center gap-1 rounded-md px-3 py-2 text-sm font-medium " \
            "hover:bg-accent hover:text-accent-foreground data-[state=open]:bg-accent " \
            "ring-offset-background focus-visible:outline-none focus-visible:ring-2 " \
            "focus-visible:ring-ring focus-visible:ring-offset-2",
            user_class
          )
        ) do
          yield if block_given?
        end
      end
    end
  end
end
