# frozen_string_literal: true

module Views
  module Pages
    class Home < Views::Base
      def view_template
        render ::Components::Site::Layout.new(title: "Wabi — Beautifully imperfect components for Rails", chrome: :bare) do
          # Hero
          section(class: "container mx-auto pt-20 pb-12 px-4 text-center max-w-3xl") do
            h1(class: "text-5xl md:text-6xl font-bold tracking-tight mb-6 text-foreground") do
              plain "Beautifully imperfect "
              span(class: "text-primary") { "components" }
              plain " for Rails."
            end
            p(class: "text-lg text-muted-foreground mb-8") do
              "Phlex-native components, copy-paste philosophy, Tailwind themed, accessible. " \
              "Open source. Built for Rails 8."
            end
            div(class: "flex flex-wrap justify-center gap-3") do
              a(href: "/docs/getting-started",
                class: "inline-flex items-center justify-center rounded-md text-sm font-medium " \
                       "h-11 px-8 bg-primary text-primary-foreground hover:bg-primary/90") { "Get started" }
              a(href: "/docs/components",
                class: "inline-flex items-center justify-center rounded-md text-sm font-medium " \
                       "h-11 px-8 border border-input bg-background hover:bg-accent " \
                       "hover:text-accent-foreground") { "Browse components" }
            end
          end

          # Live demo: a quick taste of components painted with the active theme.
          section(class: "container mx-auto py-12 px-4 max-w-4xl") do
            h2(class: "text-3xl font-bold text-center mb-2 text-foreground") { "Theming, your way" }
            p(class: "text-muted-foreground text-center mb-8") do
              plain "Switch palettes with the theme picker in the nav. The whole site repaints — try "
              a(href: "/docs/themes", class: "underline hover:text-foreground") { "the gallery" }
              plain "."
            end
            div(class: "rounded-lg border border-border p-8 bg-card text-card-foreground") do
              div(class: "grid md:grid-cols-2 gap-4") do
                render ::Components::UI::Card.new do
                  render ::Components::UI::CardHeader.new do
                    render ::Components::UI::CardTitle.new       { "Onboarding" }
                    render ::Components::UI::CardDescription.new { "Complete your profile to continue." }
                  end
                  render ::Components::UI::CardFooter.new do
                    render ::Components::UI::Button.new { "Continue" }
                  end
                end
                render ::Components::UI::Card.new do
                  render ::Components::UI::CardHeader.new do
                    render ::Components::UI::CardTitle.new       { "Account" }
                    render ::Components::UI::CardDescription.new { "Manage notification preferences." }
                  end
                  render ::Components::UI::CardContent.new do
                    div(class: "flex items-center gap-2") do
                      render ::Components::UI::Switch.new(id: "n", name: "n")
                      render ::Components::UI::Label.new(for_: "n") { "Email notifications" }
                    end
                  end
                end
              end
            end
          end

          # Quick install
          section(class: "container mx-auto py-12 px-4 max-w-3xl") do
            h2(class: "text-3xl font-bold text-center mb-6 text-foreground") { "30-second setup" }
            render ::Components::Site::CodeBlock.new(language: "shell", source: <<~SHELL)
              bundle add wabi
              bin/rails g wabi:install
              bin/rails g wabi:add button card dialog
            SHELL
          end

          # Why Wabi
          section(class: "container mx-auto py-12 px-4 max-w-5xl") do
            h2(class: "text-3xl font-bold text-center mb-8 text-foreground") { "Why Wabi" }
            div(class: "grid md:grid-cols-3 gap-6") do
              feature_card("You own the code",
                           "Components live in your app. Modify freely. Customization is the point, not the exception.")
              feature_card("Phlex-native",
                           "Composition like Ruby classes, not template strings. IDE-tab into reasoning at code speed.")
              feature_card("WCAG-AA",
                           "Keyboard nav, screen reader announcements, focus management, inert on closed overlays — handled.")
            end
          end

          footer(class: "border-t border-border mt-20") do
            div(class: "container mx-auto py-6 px-4 text-sm text-muted-foreground") do
              "Open source, MIT. Made with care."
            end
          end
        end
      end

      private

      def feature_card(title, body)
        div(class: "rounded-lg border border-border p-6 bg-card text-card-foreground") do
          h3(class: "text-lg font-semibold mb-2") { title }
          p(class: "text-sm text-muted-foreground") { body }
        end
      end
    end
  end
end
