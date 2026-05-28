# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Form < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/form.rb
          app/components/ui/form_field.rb
          app/components/ui/form_label.rb
          app/components/ui/form_description.rb
          app/components/ui/form_message.rb
        ].freeze

        # Minimal ActiveModel-shaped value object for the example.
        # FormMessage calls `.errors[field].first` — that's all we need to fake.
        FakeErrors = Struct.new(:hash) do
          def [](field) = hash[field] || []
          def any?      = hash.any?
        end

        FakeUser = Struct.new(:email, :errors_hash, keyword_init: true) do
          def errors             = FakeErrors.new(errors_hash || {})
          def to_model           = self
          def model_name         = ActiveModel::Name.new(self.class, nil, "FakeUser")
          def persisted?         = false
          def to_key             = nil
          def to_partial_path    = "fake_users/fake_user"
        end

        def view_template
          fake_user_err = FakeUser.new(email: "not-an-email",
                                       errors_hash: { email: ["is not a valid email"] })

          render ::Components::Site::Layout.new(title: "Form", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Form" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add form",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Form wraps Rails' form_with and yields the form builder so you can keep " \
                "using form.email_field, form.text_area, etc. with full ActiveModel / " \
                "ActiveRecord integration."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Form.new(model: @user, url: "#") do |form|
                  render Components::UI::FormField.new do
                    render Components::UI::FormLabel.new(for: "form_email") { "Email" }
                    form.email_field :email,
                      class: "h-10 w-full rounded-md border border-input bg-background " \
                             "px-3 py-2 text-sm",
                      id: "form_email"
                    render Components::UI::FormDescription.new { "We'll never share your email." }
                    render Components::UI::FormMessage.new(model: @user, field: :email)
                  end

                  form.submit "Save",
                    class: "h-10 rounded-md bg-primary text-primary-foreground px-4"
                end
              RUBY
                render ::Components::UI::Form.new(model: fake_user_err, url: "#", scope: :fake_user) do |form|
                  render ::Components::UI::FormField.new do
                    render ::Components::UI::FormLabel.new(for: "fake_user_email") { "Email" }
                    form.email_field :email,
                      class: "h-10 w-full rounded-md border border-input bg-background " \
                             "px-3 py-2 text-sm",
                      id: "fake_user_email"
                    render ::Components::UI::FormDescription.new { "We'll never share your email." }
                    render ::Components::UI::FormMessage.new(model: fake_user_err, field: :email)
                  end

                  form.submit "Save",
                    class: "h-10 rounded-md bg-primary text-primary-foreground px-4"
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
                li { "FormLabel uses for= to associate with the input id." }
                li { "FormDescription is intended to be referenced via aria-describedby on the input (app wiring)." }
                li { "FormMessage is intended to be referenced via aria-describedby on the input when an error is present." }
                li { "Form yields the standard Rails form builder so all native input helpers (email_field, text_area, etc.) keep working." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "form", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
