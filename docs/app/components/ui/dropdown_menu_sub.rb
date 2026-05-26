# frozen_string_literal: true

require "date"

module Components
  module UI
    # Submenu wrapper. Marks a nested-menu boundary; the parent
    # `wabi--dropdown-menu` controller creates a child Zag menu machine
    # for each `sub` target it finds and wires parent.setChild /
    # child.setParent. The `class: "contents"` makes this wrapper invisible
    # to CSS layout so the sub-trigger renders inline with its menu
    # siblings and the sub-content floats independently.
    class DropdownMenuSub < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        div(
          data: { "wabi--dropdown-menu-target": "sub" },
          class: "contents"
        ) do
          yield if block_given?
        end
      end
    end
  end
end
