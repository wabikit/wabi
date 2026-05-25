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
          end
        end
      end
    end
  end
end
