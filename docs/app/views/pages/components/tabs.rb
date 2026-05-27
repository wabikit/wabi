# frozen_string_literal: true

module Views
  module Pages
    module Components
      class Tabs < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/tabs.rb
          app/components/ui/tabs_list.rb
          app/components/ui/tabs_trigger.rb
          app/components/ui/tabs_content.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Tabs", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Tabs" }
              p(class: "text-muted-foreground mb-8") do
                "Tab list with keyboard arrow navigation. Supports automatic (default) and " \
                "manual activation modes via @zag-js/tabs."
              end

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add tabs\nbin/importmap pin @zag-js/tabs\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Tabs.new(value: "account") do
                  render Components::UI::TabsList.new do
                    render Components::UI::TabsTrigger.new(value: "account")  { "Account" }
                    render Components::UI::TabsTrigger.new(value: "password") { "Password" }
                  end
                  render Components::UI::TabsContent.new(value: "account")  { p { "Account body" } }
                  render Components::UI::TabsContent.new(value: "password") { p { "Password body" } }
                end
              RUBY
                render ::Components::UI::Tabs.new(value: "account") do
                  render ::Components::UI::TabsList.new do
                    render ::Components::UI::TabsTrigger.new(value: "account")  { "Account" }
                    render ::Components::UI::TabsTrigger.new(value: "password") { "Password" }
                  end
                  render ::Components::UI::TabsContent.new(value: "account") do
                    p(class: "text-sm text-muted-foreground") { "Manage your account settings here." }
                  end
                  render ::Components::UI::TabsContent.new(value: "password") do
                    p(class: "text-sm text-muted-foreground") { "Change your password." }
                  end
                end
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "role=\"tablist\" / role=\"tab\" / role=\"tabpanel\" anatomy." }
                li { "←/→ arrow keys navigate between triggers; Home/End jump to first/last." }
                li { "data-[state=active] styles applied to the active trigger (bg-background + shadow)." }
                li { "Inactive tabpanels render with hidden attribute; the active panel becomes tabbable (tabindex=0)." }
                li { "Automatic vs manual activation: pass activation_mode: :manual if focusing a trigger shouldn't switch the panel." }
              end
            end
          end
        end
      end
    end
  end
end
