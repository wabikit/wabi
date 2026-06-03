# frozen_string_literal: true

module Components
  module UI
    class SidebarMenuCollapsible < Wabi::Base
      SUMMARY = "flex w-full items-center gap-2 overflow-hidden rounded-md px-2 py-1.5 text-left " \
                "text-sm text-sidebar-foreground outline-none transition-colors cursor-pointer select-none " \
                "list-none [&::-webkit-details-marker]:hidden " \
                "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground " \
                "focus-visible:ring-2 focus-visible:ring-sidebar-ring " \
                "group-data-[state=collapsed]/sidebar:justify-center " \
                "group-data-[state=collapsed]/sidebar:[&>span]:hidden " \
                "group-data-[state=collapsed]/sidebar:[&>.chevron]:hidden"

      def initialize(label:, icon: nil, default_open: false, **attrs)
        @label        = label
        @icon         = icon
        @default_open = default_open
        @attrs        = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        details(**@attrs, open: (@default_open ? true : nil), class: merge_class("group/collapsible", user_class)) do
          summary(class: SUMMARY) do
            raw(safe(@icon)) if @icon
            span { @label }
            raw(safe(chevron))
          end
          yield if block
        end
      end

      private

      def chevron
        %(<svg class="chevron ml-auto h-4 w-4 shrink-0 transition-transform duration-200 group-[[open]]/collapsible:rotate-90" ) +
          %(xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" ) +
          %(stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>)
      end
    end
  end
end
