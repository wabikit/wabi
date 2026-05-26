# frozen_string_literal: true

module Views
  module Pages
    class Home < Views::Base
      def view_template
        render Components::Site::Layout.new(title: "Wabi") do
          main(class: "container mx-auto py-16 px-4") do
            h1(class: "text-4xl font-bold mb-4") { "Wabi" }
            p(class: "text-muted-foreground mb-8") { "Beautifully imperfect components for Rails." }
            div(class: "flex gap-3 flex-wrap") do
              render Components::UI::Button.new                          { "Primary" }
              render Components::UI::Button.new(appearance: :secondary)   { "Secondary" }
              render Components::UI::Button.new(appearance: :destructive) { "Destructive" }
              render Components::UI::Button.new(appearance: :outline)     { "Outline" }
              render Components::UI::Button.new(appearance: :ghost)       { "Ghost" }
              render Components::UI::Button.new(appearance: :link)        { "Link" }
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Form fields" }
              div(class: "max-w-sm space-y-4") do
                div(class: "space-y-2") do
                  render Components::UI::Label.new(for_: "email") { "Email" }
                  render Components::UI::Input.new(id: "email", type: :email, placeholder: "you@example.com")
                end
                div(class: "space-y-2") do
                  render Components::UI::Label.new(for_: "bio") { "Bio" }
                  render Components::UI::Textarea.new(id: "bio", rows: 4)
                end
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Checkbox" }
              div(class: "flex items-center gap-2") do
                render Components::UI::Checkbox.new(id: "terms", name: "terms")
                render Components::UI::Label.new(for_: "terms") { "Accept terms" }
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Switch" }
              div(class: "flex items-center gap-2") do
                render Components::UI::Switch.new(id: "notifications", name: "notifications")
                render Components::UI::Label.new(for_: "notifications") { "Email notifications" }
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Card" }
              div(class: "max-w-md") do
                render Components::UI::Card.new do
                  render Components::UI::CardHeader.new do
                    render Components::UI::CardTitle.new { "Onboarding" }
                    render Components::UI::CardDescription.new { "Complete your profile to continue." }
                  end
                  render Components::UI::CardContent.new do
                    p { "This is the card body content." }
                  end
                  render Components::UI::CardFooter.new do
                    render Components::UI::Button.new { "Continue" }
                  end
                end
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Badge" }
              div(class: "flex gap-2") do
                render Components::UI::Badge.new                            { "Primary" }
                render Components::UI::Badge.new(appearance: :secondary)    { "Secondary" }
                render Components::UI::Badge.new(appearance: :destructive)  { "Destructive" }
                render Components::UI::Badge.new(appearance: :outline)      { "Outline" }
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Separator" }
              div(class: "max-w-md") do
                p { "Above separator" }
                render Components::UI::Separator.new(class: "my-4")
                p { "Below separator" }
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Alert" }
              div(class: "max-w-xl space-y-4") do
                render Components::UI::Alert.new do
                  render Components::UI::AlertTitle.new       { "Heads up!" }
                  render Components::UI::AlertDescription.new { "You can add components to your app using the CLI." }
                end
                render Components::UI::Alert.new(appearance: :destructive) do
                  render Components::UI::AlertTitle.new       { "Error" }
                  render Components::UI::AlertDescription.new { "Your session has expired. Please log in again." }
                end
              end
            end

            section(class: "mt-12") do
              h2(class: "text-2xl font-semibold mb-4") { "Avatar" }
              div(class: "flex gap-4 items-center") do
                render Components::UI::Avatar.new do
                  render Components::UI::AvatarImage.new(src: "https://github.com/OscarOrtega.png", alt: "Oscar")
                  render Components::UI::AvatarFallback.new { "OO" }
                end
                render Components::UI::Avatar.new(class: "h-16 w-16") do
                  render Components::UI::AvatarFallback.new { "JD" }
                end
              end
            end
          end
        end
      end
    end
  end
end
