# frozen_string_literal: true

module Components
  module UI
    class SidebarGroup < Wabi::Base
      variants { base "relative flex w-full min-w-0 flex-col p-2" }

      SUMMARY = "flex h-8 shrink-0 cursor-pointer select-none items-center px-2 text-xs font-medium " \
                "text-muted-foreground list-none [&::-webkit-details-marker]:hidden " \
                "transition-[opacity,height] duration-200 motion-reduce:transition-none " \
                "group-data-[state=collapsed]/sidebar:h-0 " \
                "group-data-[state=collapsed]/sidebar:opacity-0 " \
                "group-data-[state=collapsed]/sidebar:overflow-hidden"

      def initialize(collapsible: false, label: nil, default_open: true, **attrs)
        @collapsible  = collapsible
        @label        = label
        @default_open = default_open
        @attrs        = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        unless @collapsible
          return div(**@attrs, class: merge_class(tokens, user_class)) { yield if block }
        end

        details(**@attrs, open: (@default_open ? true : nil),
                class: merge_class(tokens, "group/collapsible-group wabi-collapsible", user_class)) do
          summary(class: SUMMARY) do
            span { @label }
            raw(safe(chevron))
          end
          yield if block
        end
      end

      private

      def chevron
        %(<svg class="ml-auto h-3.5 w-3.5 shrink-0 transition-transform duration-200 motion-reduce:transition-none group-[[open]]/collapsible-group:rotate-90" ) +
          %(xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" ) +
          %(stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>)
      end
    end
  end
end
