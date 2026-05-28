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
                "Wabi's Toast uses a vanilla JS controller — @zag-js/toast group machine is deferred to v0.6."
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
                "Click the buttons below to spawn one of the three appearance variants."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                # In a Rails controller action:
                # render turbo_stream: turbo_stream.wabi_toast(
                #   title: "Saved", description: "Profile updated.", appearance: :success
                # )
                #
                # The demo below uses the wabi--toast-demo Stimulus controller to
                # clone a <template> and append it to the Toaster (mimicking the
                # Turbo Stream append pattern client-side).
                render Components::UI::Toaster.new
              RUBY
                div(
                  data: { controller: "wabi--toast-demo" },
                  class: "flex flex-wrap gap-2"
                ) do
                  render ::Components::UI::Toaster.new

                  button(
                    type: "button",
                    data: {
                      action: "click->wabi--toast-demo#spawn",
                      "wabi--toast-demo-key-param": "info",
                    },
                    class: "rounded-md border border-input bg-background px-4 py-2 text-sm hover:bg-muted"
                  ) { "Info toast" }

                  button(
                    type: "button",
                    data: {
                      action: "click->wabi--toast-demo#spawn",
                      "wabi--toast-demo-key-param": "success",
                    },
                    class: "rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm hover:opacity-90"
                  ) { "Success toast" }

                  button(
                    type: "button",
                    data: {
                      action: "click->wabi--toast-demo#spawn",
                      "wabi--toast-demo-key-param": "destructive",
                    },
                    class: "rounded-md bg-destructive text-destructive-foreground px-4 py-2 text-sm hover:opacity-90"
                  ) { "Destructive toast" }

                  template(
                    data: {
                      "wabi--toast-demo-target": "template",
                      "wabi-key": "info",
                    }
                  ) do
                    render ::Components::UI::Toast.new(
                      title: "Info",
                      description: "Something happened that you should know about.",
                      appearance: :info
                    )
                  end

                  template(
                    data: {
                      "wabi--toast-demo-target": "template",
                      "wabi-key": "success",
                    }
                  ) do
                    render ::Components::UI::Toast.new(
                      title: "Success",
                      description: "Your changes have been saved.",
                      appearance: :success
                    )
                  end

                  template(
                    data: {
                      "wabi--toast-demo-target": "template",
                      "wabi-key": "destructive",
                    }
                  ) do
                    render ::Components::UI::Toast.new(
                      title: "Destructive",
                      description: "Something went wrong. Please try again.",
                      appearance: :destructive
                    )
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
                li { "role=\"status\" + aria-live=\"polite\" + aria-atomic=\"true\" on every toast — appearance is purely visual." }
                li { "auto-dismiss after duration_ms (default 5s); hover pauses the timer so users have time to read." }
                li { "each toast has a manual close button (×) for keyboard / screen-reader users." }
                li { "for urgent / destructive messages pair toasts with an inline error message in those flows, or wait for the @zag-js/toast group machine in v0.6." }
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
