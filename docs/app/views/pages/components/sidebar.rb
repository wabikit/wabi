# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Sidebar < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/sidebar_provider.rb
          app/components/ui/sidebar.rb
          app/components/ui/sidebar_menu_button.rb
          app/components/ui/sidebar_trigger.rb
          app/javascript/controllers/wabi/sidebar_controller.js
        ].freeze

        NAV = [
          { label: "Home",     icon: %(<rect width="18" height="18" x="3" y="3" rx="2"/><path d="M9 3v18"/>), active: true },
          { label: "Inbox",    icon: %(<rect width="20" height="16" x="2" y="4" rx="2"/><path d="m22 7-10 5L2 7"/>), active: false },
          { label: "Settings", icon: %(<circle cx="12" cy="12" r="3"/><path d="M12 2v2m0 16v2M2 12h2m16 0h2"/>), active: false },
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Sidebar", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Sidebar" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(source: "bin/rails g wabi:add sidebar", language: "shell")

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              p(class: "text-muted-foreground mb-4 text-sm") do
                plain "Click the trigger to collapse the rail to icons (hover an icon for its label). "
                plain "On narrow screens it becomes an off-canvas panel."
              end
              div(class: "rounded-lg border border-border overflow-hidden h-80") do
                render ::Components::UI::SidebarProvider.new(class: "h-full min-h-0") do
                  render ::Components::UI::Sidebar.new(class: "lg:!h-full lg:!sticky lg:!top-0") do
                    render ::Components::UI::SidebarHeader.new do
                      span(class: "px-2 font-semibold group-data-[state=collapsed]/sidebar:hidden") { "Acme" }
                      render ::Components::UI::SidebarInput.new(placeholder: "Search…")
                    end
                    render ::Components::UI::SidebarContent.new do
                      render ::Components::UI::SidebarGroup.new(collapsible: true, label: "Platform", default_open: true) do
                        render ::Components::UI::SidebarMenu.new(data: { controller: "demo--sidebar-nav", action: "click->demo--sidebar-nav#select" }) do
                          NAV.each do |item|
                            render ::Components::UI::SidebarMenuItem.new do
                              render ::Components::UI::SidebarMenuButton.new(active: item[:active], tooltip: item[:label]) do
                                raw(safe(%(<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">#{item[:icon]}</svg>)))
                                span { item[:label] }
                              end
                            end
                          end
                          # Item with a count badge
                          render ::Components::UI::SidebarMenuItem.new do
                            render ::Components::UI::SidebarMenuButton.new(tooltip: "Inbox") do
                              raw(safe(%(<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect width="20" height="16" x="2" y="4" rx="2"/><path d="m22 7-10 5L2 7"/></svg>)))
                              span { "Inbox" }
                            end
                            render ::Components::UI::SidebarMenuBadge.new { "12" }
                          end
                          # Collapsible submenu (expands only when the rail is expanded)
                          render ::Components::UI::SidebarMenuItem.new do
                            render ::Components::UI::SidebarMenuCollapsible.new(
                              label: "Projects", default_open: true,
                              icon: %(<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" class="shrink-0"><path d="M3 7h18M3 12h18M3 17h18"/></svg>)
                            ) do
                              render ::Components::UI::SidebarMenuSub.new do
                                render ::Components::UI::SidebarMenuSubItem.new do
                                  render ::Components::UI::SidebarMenuSubButton.new(active: true) { "Apollo" }
                                end
                                render ::Components::UI::SidebarMenuSubItem.new do
                                  render ::Components::UI::SidebarMenuSubButton.new { "Gemini" }
                                end
                              end
                            end
                          end
                        end
                      end
                      render ::Components::UI::SidebarGroup.new do
                        render ::Components::UI::SidebarGroupLabel.new { "Loading" }
                        render ::Components::UI::SidebarMenu.new do
                          3.times do
                            render ::Components::UI::SidebarMenuItem.new do
                              render ::Components::UI::SidebarMenuSkeleton.new
                            end
                          end
                        end
                      end
                    end
                    render ::Components::UI::SidebarFooter.new do
                      span(class: "px-2 text-xs text-muted-foreground group-data-[state=collapsed]/sidebar:hidden") { "v1.0" }
                    end
                  end
                  div(class: "flex-1 p-4") do
                    render ::Components::UI::SidebarTrigger.new
                    p(class: "mt-4 text-sm text-muted-foreground") { "Main content area." }
                  end
                end
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}", class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "variants", class: "text-2xl font-semibold mt-8 mb-4") { "Shell variants" }
              p(class: "text-muted-foreground mb-4 text-sm") do
                plain "Pass "
                code(class: "font-mono text-foreground") { "variant:" }
                plain " to SidebarProvider: "
                code(class: "font-mono text-foreground") { ":sidebar" }
                plain " (default), "
                code(class: "font-mono text-foreground") { ":floating" }
                plain " (the rail becomes a detached card), or "
                code(class: "font-mono text-foreground") { ":inset" }
                plain " (the main content, wrapped in "
                code(class: "font-mono text-foreground") { "SidebarInset" }
                plain ", floats as a rounded card over a sidebar-colored background)."
              end
              render ::Components::Site::CodeBlock.new(language: "ruby", source: <<~RUBY)
                render Components::UI::SidebarProvider.new(variant: :inset) do
                  render Components::UI::Sidebar.new do
                    # … header / content / footer …
                  end
                  render Components::UI::SidebarInset.new do
                    # … your page; include a SidebarTrigger somewhere …
                  end
                end
              RUBY

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "Menu items are real <a>/<button> elements; the active item carries aria-current=\"page\"." }
                li { "Collapsed (icon) mode shows each item's label via a tooltip, so the icon-only rail stays labelled." }
                li { "On mobile the panel is off-canvas: focus moves to it on open, the rest of the page is inert, and Escape (or a backdrop click) closes it." }
                li { "Collapse state persists across visits in localStorage." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "sidebar", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
