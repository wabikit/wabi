# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class CollapsibleContent < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--collapsible-target": "content" },
          "data-state": "closed",
          class: merge_class(
            "grid grid-rows-[0fr] transition-[grid-template-rows] duration-200 ease-out " \
            "motion-reduce:transition-none data-[state=open]:grid-rows-[1fr]",
            user_class
          )
        ) do
          div(class: "overflow-hidden") do
            yield if block_given?
          end
        end
      end
    end
  end
end
