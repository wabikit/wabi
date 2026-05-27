# frozen_string_literal: true

module Components
  module Site
    class SidebarToggle < Components::Base
      def view_template
        button(type: "button",
               class: "lg:hidden inline-flex items-center justify-center h-9 w-9 rounded-md " \
                      "text-muted-foreground hover:text-foreground hover:bg-accent",
               "aria-label": "Toggle navigation",
               data: { controller: "site--sidebar", action: "click->site--sidebar#toggle" }) do
          # Hamburger SVG (3 lines)
          raw safe('<svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2"><line x1="3" y1="6" x2="17" y2="6"/><line x1="3" y1="10" x2="17" y2="10"/><line x1="3" y1="14" x2="17" y2="14"/></svg>')
        end
      end
    end
  end
end
