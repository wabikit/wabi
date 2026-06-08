# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class RatingGroupItem < Wabi::Base
      STAR_PATH = "M11.525 2.295a.53.53 0 0 1 .95 0l2.31 4.679a2.123 2.123 0 0 0 1.595 1.16l5.166.756a.53.53 0 0 1 .294.904l-3.736 3.638a2.123 2.123 0 0 0-.611 1.878l.882 5.14a.53.53 0 0 1-.771.56l-4.618-2.428a2.122 2.122 0 0 0-1.973 0L6.396 21.01a.53.53 0 0 1-.77-.56l.881-5.139a2.122 2.122 0 0 0-.611-1.879L2.16 9.795a.53.53 0 0 1 .294-.906l5.165-.755a2.122 2.122 0 0 0 1.597-1.16z"

      OUTLINE_SVG = %(<svg aria-hidden="true" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="absolute inset-0 h-full w-full"><path d="#{STAR_PATH}"/></svg>)
      FILLED_SVG  = %(<svg aria-hidden="true" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="absolute inset-0 h-full w-full text-yellow-400 opacity-0 group-data-[highlighted]:opacity-100 group-data-[half]:[clip-path:inset(0_50%_0_0)]"><path d="#{STAR_PATH}"/></svg>)

      def initialize(index:, **attrs)
        @index = index
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        span(
          data: { "wabi--rating-group-target": "item", "wabi-index": @index.to_s },
          class: merge_class(
            "group relative inline-block h-6 w-6 cursor-pointer text-muted-foreground " \
            "transition-colors motion-reduce:transition-none data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50 " \
            "data-[readonly]:cursor-default rounded-sm outline-none " \
            "focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
            user_class
          )
        ) do
          raw(safe(OUTLINE_SVG))
          raw(safe(FILLED_SVG))
        end
      end
    end
  end
end
