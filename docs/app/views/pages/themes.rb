# frozen_string_literal: true

module Views
  module Pages
    class Themes < Views::Base
      THEMES = %w[default slate stone zinc rose blue green violet].freeze

      def view_template
        render Components::Site::Layout.new(title: "Themes") do
          main(class: "container mx-auto py-12 px-4 max-w-5xl") do
            h1(class: "text-4xl font-bold mb-2") { "Themes" }
            p(class: "text-muted-foreground mb-8") do
              plain "Wabi ships 8 pre-built palettes. Switch the active one in a Rails app with "
              code(class: "px-1.5 py-0.5 rounded bg-muted text-sm") { "bin/rails g wabi:theme <slug>" }
              plain "."
            end

            div(class: "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4") do
              THEMES.each do |slug|
                # Each card forces its own data-theme on the container, so the
                # nested components paint with that theme's tokens regardless
                # of what the user picked globally. data-mode is intentionally
                # left to inherit from <html> so the user's dark/light choice
                # is reflected across all swatches.
                div(
                  "data-theme": slug,
                  class: "rounded-lg border border-border bg-background p-5"
                ) do
                  h3(class: "text-lg font-semibold mb-3 text-foreground") { slug.capitalize }
                  div(class: "flex flex-col gap-2") do
                    render Components::UI::Button.new                        { "Primary" }
                    render Components::UI::Button.new(appearance: :secondary) { "Secondary" }
                    render Components::UI::Button.new(appearance: :outline)   { "Outline" }
                    div(class: "flex gap-2 mt-1") do
                      render Components::UI::Badge.new                         { "Badge" }
                      render Components::UI::Badge.new(appearance: :secondary) { "Secondary" }
                    end
                  end
                  button(
                    type: "button",
                    class: "mt-5 w-full text-xs text-muted-foreground hover:text-foreground " \
                           "border-t border-border pt-3",
                    data: {
                      action: "click->wabi--theme#setTheme",
                      "wabi--theme-theme-param": slug,
                    }
                  ) { "Apply this theme" }
                end
              end
            end
          end
        end
      end
    end
  end
end
