# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Avatar < Views::Base
        SOURCE_PATHS = %w[app/components/ui/avatar.rb app/components/ui/avatar_image.rb app/components/ui/avatar_fallback.rb].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Avatar", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Avatar" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add avatar",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Avatar.new do
                  render Components::UI::AvatarImage.new(src: "/avatar-sample.svg", alt: "Jane Doe")
                  render Components::UI::AvatarFallback.new { "JD" }
                end
              RUBY
                render ::Components::UI::Avatar.new do
                  render ::Components::UI::AvatarImage.new(src: "/avatar-sample.svg", alt: "Jane Doe")
                  render ::Components::UI::AvatarFallback.new { "JD" }
                end
              end

              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Avatar.new do
                  render Components::UI::AvatarFallback.new { "OO" }
                end
              RUBY
                render ::Components::UI::Avatar.new do
                  render ::Components::UI::AvatarFallback.new { "OO" }
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
                li { "the alt: attribute on AvatarImage is required for screen readers; pass a meaningful name or empty string for decorative use." }
                li { "when the image fails to load, AvatarFallback renders automatically (usually initials)." }
                li { 'for purely decorative avatars in lists, consider aria-hidden="true" on the wrapper to suppress redundant announcements.' }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "avatar", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
