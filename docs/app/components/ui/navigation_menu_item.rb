# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class NavigationMenuItem < Wabi::Base
      def initialize(value:, **attrs)
        @value = value
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        li(
          data: { "wabi--navigation-menu-target": "item", "wabi-value": @value.to_s },
          class: merge_class("relative", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
