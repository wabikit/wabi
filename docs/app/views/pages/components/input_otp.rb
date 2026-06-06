# frozen_string_literal: true

module Views
  module Pages
    module Components
      class InputOtp < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/input_otp.rb
          app/javascript/controllers/wabi/input_otp_controller.js
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Input OTP", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Input OTP" }
              p(class: "text-muted-foreground mb-8") do
                "An accessible one-time-password input that wires individual character slots " \
                "into a single hidden field, powered by @zag-js/pin-input. " \
                "Supports numeric and alphanumeric modes, masking, and configurable length."
              end

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add input_otp\n" \
                        "bin/importmap pin @zag-js/pin-input @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/pin-input and @zag-js/vanilla at 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only fetches the main entry and leaves submodules unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::InputOtp.new(name: "user[otp]")
              RUBY
                render ::Components::UI::InputOtp.new(name: "user[otp]")
              end

              h2(id: "masked", class: "text-2xl font-semibold mt-8 mb-4") { "Masked / 4 digits" }
              p(class: "text-muted-foreground mb-4 text-sm") do
                "Pass mask: true to obscure typed characters (like a PIN), and length: to change the slot count."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::InputOtp.new(name: "pin", length: 4, mask: true)
              RUBY
                render ::Components::UI::InputOtp.new(name: "pin", length: 4, mask: true)
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}", class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "Each slot renders as a text input; arrow keys move focus between slots." }
                li { "autocomplete=\"one-time-code\" is set by default (otp: true) for browser autofill." }
                li { "Paste is supported — the controller distributes pasted characters across slots." }
                li { "The assembled value is mirrored to a hidden input so the named field submits correctly." }
                li { "mask: true switches each slot to type=\"password\" rendering without changing the underlying API." }
              end
            end
          end
        end
      end
    end
  end
end
