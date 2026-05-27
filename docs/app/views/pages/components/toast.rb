# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Toast < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/toast.rb
          app/components/ui/toaster.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Toast", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Toast" }
              p(class: "text-muted-foreground mb-6") { description }
              p(class: "text-sm text-muted-foreground mb-8") do
                "Wabi's v0.4 Toast uses a vanilla JS controller — @zag-js/toast group machine is queued for v0.5."
              end

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add toast",
                language: "shell"
              )

              h2(id: "setup", class: "text-2xl font-semibold mt-8 mb-4") { "Layout setup" }
              render ::Components::Site::CodeBlock.new(
                source: <<~RUBY,
                  # In your application layout (once, near end of <body>):
                  render Components::UI::Toaster.new
                RUBY
                language: "ruby"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              p(class: "text-sm text-muted-foreground mb-4") do
                "Toasts are dispatched from a Rails action via Turbo Stream. " \
                "The three appearance variants — :info (default), :success, and :destructive — are shown below."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                # Dispatch from a controller action:
                # turbo_stream.append "wabi-toaster",
                #   Components::UI::Toast.new(title: "File saved", appearance: :success)
                #
                # All three appearances:
                render Components::UI::Toast.new(
                  title: "Info",
                  description: "Something happened that you should know about.",
                  appearance: :info
                )
                render Components::UI::Toast.new(
                  title: "Success",
                  description: "Your changes have been saved.",
                  appearance: :success
                )
                render Components::UI::Toast.new(
                  title: "Destructive",
                  description: "Something went wrong. Please try again.",
                  appearance: :destructive
                )
              RUBY
                ol(class: "flex flex-col gap-2 list-none p-0 m-0 w-80") do
                  render ::Components::UI::Toast.new(
                    title: "Info",
                    description: "Something happened that you should know about.",
                    appearance: :info
                  )
                  render ::Components::UI::Toast.new(
                    title: "Success",
                    description: "Your changes have been saved.",
                    appearance: :success
                  )
                  render ::Components::UI::Toast.new(
                    title: "Destructive",
                    description: "Something went wrong. Please try again.",
                    appearance: :destructive
                  )
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
                li { "role=\"status\" + aria-live=\"polite\" + aria-atomic=\"true\" on every toast — appearance is purely visual." }
                li { "auto-dismiss after duration_ms (default 4s); hover pauses the timer so users have time to read." }
                li { "each toast has a manual close button (X) for keyboard / screen-reader users." }
                li { "for urgent / destructive messages a screen-reader user may miss a polite announcement — pair toasts with an inline error message in those flows, or wait for the @zag-js/toast group machine in v0.5." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "toast", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
