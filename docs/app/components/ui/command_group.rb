# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class CommandGroup < Wabi::Base
      HEADING_CLASS = "px-2 py-1.5 text-xs font-medium text-muted-foreground"

      def initialize(heading: nil, **attrs)
        @heading = heading
        @attrs   = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(**@attrs, role: "group", class: merge_class("overflow-hidden p-1", user_class)) do
          h3(class: HEADING_CLASS) { @heading } if @heading
          yield if block_given?
        end
      end
    end
  end
end
