# frozen_string_literal: true

require "date"

module Components
  module UI
    class AccordionTrigger < Wabi::Base
      variants do
        base "flex flex-1 items-center justify-between py-4 text-sm font-medium " \
             "transition-all hover:underline focus-visible:outline-none " \
             "focus-visible:ring-2 focus-visible:ring-ring " \
             "[&[data-state=open]>svg]:rotate-180"
      end

      # level: (Integer 1-6, default 3) controls the heading element wrapping the
      # trigger button, mirroring CardTitle. Pass level: nil to opt out of heading
      # semantics entirely (renders a plain <div> wrapper).
      def initialize(value:, level: 3, **attrs)
        @value = value
        @level = level.nil? ? nil : level.to_i.clamp(1, 6)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        wrapper = @level.nil? ? :div : :"h#{@level}"
        send(wrapper, class: "flex") do
          button(
            type: "button",
            data: {
              "wabi--accordion-target": "trigger",
              "wabi-value": @value,
            },
            class: merge_class(tokens, user_class)
          ) do
            yield if block_given?
            raw(safe('<svg aria-hidden="true" focusable="false" class="h-4 w-4 shrink-0 transition-transform duration-200 motion-reduce:transition-none" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>'))
          end
        end
      end
    end
  end
end
