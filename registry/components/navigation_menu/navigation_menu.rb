# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class NavigationMenu < Wabi::Base
      def initialize(id: nil, orientation: :horizontal, **attrs)
        @id          = id
        @orientation = orientation
        @attrs       = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        nav(
          id: @id,
          data: {
            controller: "wabi--navigation-menu",
            "wabi--navigation-menu-orientation-value": @orientation.to_s,
          },
          class: merge_class("relative flex", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
