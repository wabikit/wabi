# frozen_string_literal: true

module Components
  module Site
    # Quick-access sun/moon button that toggles <html data-mode> between
    # "light" and "dark". Wraps the existing wabi--theme#toggleMode action,
    # which persists the choice in localStorage. Sits in the header next to
    # ThemePicker so users can flip the mode without opening a dropdown.
    class ModeToggle < Components::Base
      MOON_SVG = '<svg class="h-4 w-4 dark:hidden" viewBox="0 0 24 24" fill="none" ' \
                 'stroke="currentColor" stroke-width="2" stroke-linecap="round" ' \
                 'stroke-linejoin="round" aria-hidden="true">' \
                 '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>'

      SUN_SVG = '<svg class="h-4 w-4 hidden dark:block" viewBox="0 0 24 24" fill="none" ' \
                'stroke="currentColor" stroke-width="2" stroke-linecap="round" ' \
                'stroke-linejoin="round" aria-hidden="true">' \
                '<circle cx="12" cy="12" r="4"/>' \
                '<path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41' \
                'M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"/></svg>'

      def view_template
        button(
          type: "button",
          "aria-label": "Toggle dark mode",
          class: "inline-flex items-center justify-center rounded-md text-sm font-medium " \
                 "h-9 w-9 border border-input bg-background hover:bg-accent " \
                 "hover:text-accent-foreground",
          data: { action: "click->wabi--theme#toggleMode" }
        ) do
          raw safe(MOON_SVG)
          raw safe(SUN_SVG)
        end
      end
    end
  end
end
