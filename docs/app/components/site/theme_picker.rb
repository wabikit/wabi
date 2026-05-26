# frozen_string_literal: true

module Components
  module Site
    # Theme picker dropdown for the docs nav. Reuses `wabi--theme` controller
    # actions (setTheme / toggleMode) that already ship in the gem template.
    # The initial radio `value` is hardcoded to "default"; the controller
    # rehydrates from localStorage on `connect()`, so the visible html
    # data-theme reflects the persisted choice after page load even though
    # the server-side radio state shows "default".
    class ThemePicker < Components::Base
      THEMES = %w[default slate stone zinc rose blue green violet].freeze

      def view_template
        render Components::UI::DropdownMenu.new do
          render Components::UI::DropdownMenuTrigger.new(
            class: "inline-flex items-center justify-center rounded-md text-sm font-medium " \
                   "h-9 px-3 border border-input bg-background hover:bg-accent " \
                   "hover:text-accent-foreground"
          ) do
            plain "Theme"
            raw safe('<svg class="ml-2 h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/></svg>')
          end
          render Components::UI::DropdownMenuContent.new do
            render Components::UI::DropdownMenuLabel.new { "Palette" }
            render Components::UI::DropdownMenuRadioGroup.new(name: "wabi-theme", value: "default") do
              THEMES.each do |slug|
                render Components::UI::DropdownMenuRadioItem.new(
                  value: slug,
                  name:  "wabi-theme",
                  checked: slug == "default",
                  data: {
                    action: "click->wabi--theme#setTheme",
                    "wabi--theme-theme-param": slug,
                  }
                ) { slug.capitalize }
              end
            end
            render Components::UI::DropdownMenuSeparator.new
            render Components::UI::DropdownMenuItem.new(
              value: "toggle-mode",
              data: { action: "click->wabi--theme#toggleMode" }
            ) { "Toggle dark mode" }
          end
        end
      end
    end
  end
end
