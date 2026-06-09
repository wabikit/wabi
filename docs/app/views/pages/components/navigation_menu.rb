# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class NavigationMenu < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/navigation_menu.rb
          app/components/ui/navigation_menu_list.rb
          app/components/ui/navigation_menu_item.rb
          app/components/ui/navigation_menu_trigger.rb
          app/components/ui/navigation_menu_content.rb
          app/components/ui/navigation_menu_link.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Navigation Menu", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Navigation Menu" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(source: "bin/rails g wabi:add navigation_menu", language: "shell")

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::NavigationMenu.new do
                  render Components::UI::NavigationMenuList.new do
                    render Components::UI::NavigationMenuItem.new(value: "products") do
                      render Components::UI::NavigationMenuTrigger.new(value: "products") { "Products" }
                      render Components::UI::NavigationMenuContent.new(value: "products") do
                        render Components::UI::NavigationMenuLink.new(value: "products", href: "#") { "Analytics" }
                        render Components::UI::NavigationMenuLink.new(value: "products", href: "#") { "Automation" }
                      end
                    end
                    render Components::UI::NavigationMenuItem.new(value: "company") do
                      render Components::UI::NavigationMenuTrigger.new(value: "company") { "Company" }
                      render Components::UI::NavigationMenuContent.new(value: "company") do
                        render Components::UI::NavigationMenuLink.new(value: "company", href: "#") { "About" }
                        render Components::UI::NavigationMenuLink.new(value: "company", href: "#") { "Careers" }
                      end
                    end
                  end
                end
              RUBY
                render ::Components::UI::NavigationMenu.new do
                  render ::Components::UI::NavigationMenuList.new do
                    render ::Components::UI::NavigationMenuItem.new(value: "products") do
                      render ::Components::UI::NavigationMenuTrigger.new(value: "products") { "Products" }
                      render ::Components::UI::NavigationMenuContent.new(value: "products") do
                        render ::Components::UI::NavigationMenuLink.new(value: "products", href: "#") { "Analytics" }
                        render ::Components::UI::NavigationMenuLink.new(value: "products", href: "#") { "Automation" }
                      end
                    end
                    render ::Components::UI::NavigationMenuItem.new(value: "company") do
                      render ::Components::UI::NavigationMenuTrigger.new(value: "company") { "Company" }
                      render ::Components::UI::NavigationMenuContent.new(value: "company") do
                        render ::Components::UI::NavigationMenuLink.new(value: "company", href: "#") { "About" }
                        render ::Components::UI::NavigationMenuLink.new(value: "company", href: "#") { "Careers" }
                      end
                    end
                  end
                end
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}", class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "Triggers expose aria-expanded; arrow keys move between items, Escape closes." }
                li { "Closed panels are inert (removed from the tab order and a11y tree)." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "navigation_menu", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
