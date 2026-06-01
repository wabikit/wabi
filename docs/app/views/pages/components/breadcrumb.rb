# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Breadcrumb < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/breadcrumb.rb
          app/components/ui/breadcrumb_list.rb
          app/components/ui/breadcrumb_item.rb
          app/components/ui/breadcrumb_link.rb
          app/components/ui/breadcrumb_page.rb
          app/components/ui/breadcrumb_separator.rb
          app/components/ui/breadcrumb_ellipsis.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Breadcrumb", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Breadcrumb" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add breadcrumb",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Breadcrumb.new do
                  render Components::UI::BreadcrumbList.new do
                    render Components::UI::BreadcrumbItem.new do
                      render Components::UI::BreadcrumbLink.new(href: "/") { "Home" }
                    end
                    render Components::UI::BreadcrumbSeparator.new
                    render Components::UI::BreadcrumbItem.new do
                      render Components::UI::BreadcrumbLink.new(href: "/docs") { "Docs" }
                    end
                    render Components::UI::BreadcrumbSeparator.new
                    render Components::UI::BreadcrumbItem.new do
                      render Components::UI::BreadcrumbPage.new { "Breadcrumb" }
                    end
                  end
                end
              RUBY
                render ::Components::UI::Breadcrumb.new do
                  render ::Components::UI::BreadcrumbList.new do
                    render ::Components::UI::BreadcrumbItem.new do
                      render ::Components::UI::BreadcrumbLink.new(href: "/") { "Home" }
                    end
                    render ::Components::UI::BreadcrumbSeparator.new
                    render ::Components::UI::BreadcrumbItem.new do
                      render ::Components::UI::BreadcrumbLink.new(href: "/docs") { "Docs" }
                    end
                    render ::Components::UI::BreadcrumbSeparator.new
                    render ::Components::UI::BreadcrumbItem.new do
                      render ::Components::UI::BreadcrumbPage.new { "Breadcrumb" }
                    end
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
                li { "Breadcrumb renders a <nav> with aria-label=\"breadcrumb\" so screen readers announce it as navigation." }
                li { "BreadcrumbList renders an <ol> so screen readers enumerate items." }
                li { "BreadcrumbPage adds aria-current=\"page\" to mark the active crumb." }
                li { "BreadcrumbSeparator is aria-hidden to keep screen-reader output clean." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "breadcrumb", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
