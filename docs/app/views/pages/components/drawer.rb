# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Drawer < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/drawer.rb
          app/components/ui/drawer_trigger.rb
          app/components/ui/drawer_content.rb
          app/components/ui/drawer_header.rb
          app/components/ui/drawer_footer.rb
          app/components/ui/drawer_title.rb
          app/components/ui/drawer_description.rb
          app/components/ui/drawer_close.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Drawer", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Drawer" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add drawer\nbin/importmap pin @zag-js/dialog\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Drawer reuses Zag's dialog machine — pin @zag-js/dialog, not @zag-js/drawer."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }

              # Right
              h3(id: "example-right", class: "text-lg font-semibold mt-6 mb-3") { "Right (default)" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Drawer.new(side: :right) do
                  render Components::UI::DrawerTrigger.new(class: "...") { "Open (right)" }
                  render Components::UI::DrawerContent.new(side: :right) do
                    render Components::UI::DrawerHeader.new do
                      render Components::UI::DrawerTitle.new       { "Settings" }
                      render Components::UI::DrawerDescription.new { "Adjust your preferences below." }
                    end
                    p(class: "text-sm text-muted-foreground py-4") { "Settings panel content goes here." }
                    render Components::UI::DrawerFooter.new do
                      render Components::UI::DrawerClose.new { "Close" }
                    end
                  end
                end
              RUBY
                render ::Components::UI::Drawer.new(side: :right) do
                  render ::Components::UI::DrawerTrigger.new(
                    class: "inline-flex items-center justify-center rounded-md text-sm font-medium " \
                           "bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2"
                  ) { "Open (right)" }
                  render ::Components::UI::DrawerContent.new(side: :right) do
                    render ::Components::UI::DrawerHeader.new do
                      render ::Components::UI::DrawerTitle.new       { "Settings" }
                      render ::Components::UI::DrawerDescription.new { "Adjust your preferences below." }
                    end
                    p(class: "text-sm text-muted-foreground py-4") { "Settings panel content goes here." }
                    render ::Components::UI::DrawerFooter.new do
                      render ::Components::UI::DrawerClose.new { "Close" }
                    end
                  end
                end
              end

              # Left
              h3(id: "example-left", class: "text-lg font-semibold mt-6 mb-3") { "Left" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Drawer.new(side: :left) do
                  render Components::UI::DrawerTrigger.new(class: "...") { "Open (left)" }
                  render Components::UI::DrawerContent.new(side: :left) do
                    render Components::UI::DrawerHeader.new do
                      render Components::UI::DrawerTitle.new       { "Navigation" }
                      render Components::UI::DrawerDescription.new { "Browse sections." }
                    end
                    p(class: "text-sm text-muted-foreground py-4") { "Nav links go here." }
                    render Components::UI::DrawerFooter.new do
                      render Components::UI::DrawerClose.new { "Close" }
                    end
                  end
                end
              RUBY
                render ::Components::UI::Drawer.new(side: :left) do
                  render ::Components::UI::DrawerTrigger.new(
                    class: "inline-flex items-center justify-center rounded-md text-sm font-medium " \
                           "border border-input bg-background hover:bg-accent hover:text-accent-foreground " \
                           "h-10 px-4 py-2"
                  ) { "Open (left)" }
                  render ::Components::UI::DrawerContent.new(side: :left) do
                    render ::Components::UI::DrawerHeader.new do
                      render ::Components::UI::DrawerTitle.new       { "Navigation" }
                      render ::Components::UI::DrawerDescription.new { "Browse sections." }
                    end
                    p(class: "text-sm text-muted-foreground py-4") { "Nav links go here." }
                    render ::Components::UI::DrawerFooter.new do
                      render ::Components::UI::DrawerClose.new { "Close" }
                    end
                  end
                end
              end

              # Top
              h3(id: "example-top", class: "text-lg font-semibold mt-6 mb-3") { "Top" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Drawer.new(side: :top) do
                  render Components::UI::DrawerTrigger.new(class: "...") { "Open (top)" }
                  render Components::UI::DrawerContent.new(side: :top) do
                    render Components::UI::DrawerHeader.new do
                      render Components::UI::DrawerTitle.new       { "Notifications" }
                      render Components::UI::DrawerDescription.new { "Your recent alerts." }
                    end
                    p(class: "text-sm text-muted-foreground py-4") { "Notification list goes here." }
                    render Components::UI::DrawerFooter.new do
                      render Components::UI::DrawerClose.new { "Dismiss" }
                    end
                  end
                end
              RUBY
                render ::Components::UI::Drawer.new(side: :top) do
                  render ::Components::UI::DrawerTrigger.new(
                    class: "inline-flex items-center justify-center rounded-md text-sm font-medium " \
                           "border border-input bg-background hover:bg-accent hover:text-accent-foreground " \
                           "h-10 px-4 py-2"
                  ) { "Open (top)" }
                  render ::Components::UI::DrawerContent.new(side: :top) do
                    render ::Components::UI::DrawerHeader.new do
                      render ::Components::UI::DrawerTitle.new       { "Notifications" }
                      render ::Components::UI::DrawerDescription.new { "Your recent alerts." }
                    end
                    p(class: "text-sm text-muted-foreground py-4") { "Notification list goes here." }
                    render ::Components::UI::DrawerFooter.new do
                      render ::Components::UI::DrawerClose.new { "Dismiss" }
                    end
                  end
                end
              end

              # Bottom
              h3(id: "example-bottom", class: "text-lg font-semibold mt-6 mb-3") { "Bottom" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Drawer.new(side: :bottom) do
                  render Components::UI::DrawerTrigger.new(class: "...") { "Open (bottom)" }
                  render Components::UI::DrawerContent.new(side: :bottom) do
                    render Components::UI::DrawerHeader.new do
                      render Components::UI::DrawerTitle.new       { "Share" }
                      render Components::UI::DrawerDescription.new { "Send this item to a teammate." }
                    end
                    p(class: "text-sm text-muted-foreground py-4") { "Share options go here." }
                    render Components::UI::DrawerFooter.new do
                      render Components::UI::DrawerClose.new { "Cancel" }
                    end
                  end
                end
              RUBY
                render ::Components::UI::Drawer.new(side: :bottom) do
                  render ::Components::UI::DrawerTrigger.new(
                    class: "inline-flex items-center justify-center rounded-md text-sm font-medium " \
                           "border border-input bg-background hover:bg-accent hover:text-accent-foreground " \
                           "h-10 px-4 py-2"
                  ) { "Open (bottom)" }
                  render ::Components::UI::DrawerContent.new(side: :bottom) do
                    render ::Components::UI::DrawerHeader.new do
                      render ::Components::UI::DrawerTitle.new       { "Share" }
                      render ::Components::UI::DrawerDescription.new { "Send this item to a teammate." }
                    end
                    p(class: "text-sm text-muted-foreground py-4") { "Share options go here." }
                    render ::Components::UI::DrawerFooter.new do
                      render ::Components::UI::DrawerClose.new { "Cancel" }
                    end
                  end
                end
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}",
                   class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "Drawer uses Zag's dialog machine — focus is trapped inside while open, scroll lock applies to the body." }
                li { "Escape closes; clicking the backdrop closes; focus returns to the trigger on close." }
                li { "The side: prop is purely visual — semantics remain role=\"dialog\" + aria-modal=\"true\" regardless of slide direction." }
                li { "DrawerTitle and DrawerDescription wire aria-labelledby/aria-describedby on the dialog panel." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "drawer", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
