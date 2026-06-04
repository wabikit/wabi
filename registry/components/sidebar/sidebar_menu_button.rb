# frozen_string_literal: true

module Components
  module UI
    class SidebarMenuButton < Wabi::Base
      variants do
        base "flex w-full items-center gap-2 overflow-hidden rounded-md px-2 py-1.5 text-left " \
             "text-sm text-sidebar-foreground outline-none transition-colors " \
             "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground " \
             "focus-visible:ring-2 focus-visible:ring-sidebar-ring " \
             "disabled:pointer-events-none disabled:opacity-50 " \
             "aria-[current=page]:bg-sidebar-accent aria-[current=page]:text-sidebar-accent-foreground " \
             "aria-[current=page]:font-medium " \
             "group-data-[state=collapsed]/sidebar:justify-center " \
             "group-data-[state=collapsed]/sidebar:[&>span]:hidden"
      end

      def initialize(href: nil, active: false, tooltip: nil, **attrs)
        @href    = href
        @active  = active
        @tooltip = tooltip
        @attrs   = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        klass = merge_class(tokens, user_class)

        return render_button(klass, &block) unless @tooltip

        # Hand-rolled wabi--tooltip wrapper (Tooltip.new forces inline-block and
        # ignores attrs). The menu button element itself is the trigger (no nested
        # interactive elements). The bubble shows only when the sidebar is collapsed.
        tip = @tooltip
        div(
          class: "w-full",
          data: {
            controller: "wabi--tooltip",
            "wabi--tooltip-open-delay-value":  "0",
            "wabi--tooltip-close-delay-value": "0",
            "wabi--tooltip-portal-value":      "true",
          }
        ) do
          render_button(klass, trigger: true, &block)
          # The tooltip is a collapsed-only label. Its content portals to <body>
          # (escaping group/sidebar), so we gate on the <html data-wabi-sidebar>
          # marker the controller mirrors — hidden whenever the sidebar is expanded.
          render Components::UI::TooltipContent.new(
            class: "[[data-wabi-sidebar=expanded]_&]:hidden"
          ) { tip }
        end
      end

      private

      def render_button(klass, trigger: false, &block)
        data = trigger ? { "wabi--tooltip-target": "trigger" } : {}
        common = { "aria-current": (@active ? "page" : nil), data: data, class: klass }
        if @href
          a(href: @href, **common) { yield if block }
        else
          button(type: "button", **common) { yield if block }
        end
      end
    end
  end
end
