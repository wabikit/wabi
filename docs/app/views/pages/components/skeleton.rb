# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Skeleton < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/skeleton.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Skeleton", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Skeleton" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add skeleton",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                div(class: "flex flex-col gap-3") do
                  render Components::UI::Skeleton.new(class: "h-12 w-12 rounded-full")
                  render Components::UI::Skeleton.new(class: "h-4 w-[250px]")
                  render Components::UI::Skeleton.new(class: "h-4 w-[200px]")
                end
              RUBY
                div(class: "flex flex-col gap-3") do
                  render ::Components::UI::Skeleton.new(class: "h-12 w-12 rounded-full")
                  render ::Components::UI::Skeleton.new(class: "h-4 w-[250px]")
                  render ::Components::UI::Skeleton.new(class: "h-4 w-[200px]")
                end
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}",
                   class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "skeleton", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
