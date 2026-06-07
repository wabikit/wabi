# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class NavigationMenuContent < Wabi::Base
      def initialize(value:, **attrs)
        @value = value
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--navigation-menu-target": "content", "wabi-value": @value.to_s },
          "data-state": "closed",
          inert: true,
          class: merge_class(
            "absolute left-0 top-full mt-1.5 min-w-48 rounded-md border border-input bg-popover p-2 " \
            "text-popover-foreground shadow-md outline-none transition-opacity duration-200 ease-out " \
            "motion-reduce:transition-none data-[state=open]:opacity-100 data-[state=closed]:opacity-0 " \
            "data-[state=closed]:pointer-events-none",
            user_class
          )
        ) do
          yield if block_given?
        end
      end
    end
  end
end
