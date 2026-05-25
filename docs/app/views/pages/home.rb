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
          end
        end
      end
    end
  end
end
