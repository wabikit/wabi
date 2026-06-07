# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class NavigationMenuLink < Wabi::Base
      def initialize(value:, href: "#", **attrs)
        @value = value
        @href  = href
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        a(
          href: @href,
          data: { "wabi--navigation-menu-target": "link", "wabi-value": @value.to_s },
          class: merge_class(
            "block rounded px-2 py-1.5 text-sm hover:bg-accent hover:text-accent-foreground " \
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
