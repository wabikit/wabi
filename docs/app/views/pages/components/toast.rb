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
                "Wabi v0.5 Toast is powered by the @zag-js/toast group machine — max, gap, swipe, and pause-on-hover are all handled by the Toaster controller."
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
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Toaster.new(id: "demo-toaster", max: 3, placement: "bottom-end")

                # Buttons trigger window.wabiToaster.create() via data-toast-payload
                button(
                  type: "button",
                  data: { "toast-payload": '{"title":"Saved","description":"Profile updated.","type":"success"}' },
                  class: "js-toast-btn rounded-md bg-primary text-primary-foreground px-4 py-2"
                ) { "Show success toast" }

                button(
                  type: "button",
                  data: { "toast-payload": '{"title":"Boom","description":"Something failed.","type":"error"}' },
                  class: "js-toast-btn rounded-md bg-destructive text-destructive-foreground px-4 py-2 ml-2"
                ) { "Show error toast" }
              RUBY
                render ::Components::UI::Toaster.new(id: "demo-toaster", max: 3, placement: "bottom-end")

                button(
                  type: "button",
                  data: { "toast-payload": '{"title":"Saved","description":"Profile updated.","type":"success"}' },
                  class: "js-toast-btn rounded-md bg-primary text-primary-foreground px-4 py-2"
                ) { "Show success toast" }

                button(
                  type: "button",
                  data: { "toast-payload": '{"title":"Boom","description":"Something failed.","type":"error"}' },
                  class: "js-toast-btn rounded-md bg-destructive text-destructive-foreground px-4 py-2 ml-2"
                ) { "Show error toast" }

                script do
                  plain <<~JS
                    document.querySelectorAll('.js-toast-btn').forEach(function(btn) {
                      btn.addEventListener('click', function() {
                        var payload = JSON.parse(btn.dataset.toastPayload);
                        window.wabiToaster && window.wabiToaster.create(payload);
                      });
                    });
                  JS
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
                li { "auto-dismiss after duration (default 5000ms); the Zag group machine pauses timers on group hover." }
                li { "each toast has a manual close button (×) for keyboard / screen-reader users." }
                li { "for urgent / destructive messages, pair toasts with an inline error message so screen-reader users in polite-only mode don't miss the announcement." }
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
