# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Pagination < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/pagination.rb
          app/components/ui/pagination_content.rb
          app/components/ui/pagination_item.rb
          app/components/ui/pagination_link.rb
          app/components/ui/pagination_previous.rb
          app/components/ui/pagination_next.rb
          app/components/ui/pagination_ellipsis.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Pagination", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Pagination" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add pagination",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Pagination.new do
                  render Components::UI::PaginationContent.new do
                    render Components::UI::PaginationItem.new do
                      render Components::UI::PaginationPrevious.new(href: "#")
                    end
                    render Components::UI::PaginationItem.new do
                      render Components::UI::PaginationLink.new(href: "#") { "1" }
                    end
                    render Components::UI::PaginationItem.new do
                      render Components::UI::PaginationLink.new(href: "#", active: true) { "2" }
                    end
                    render Components::UI::PaginationItem.new do
                      render Components::UI::PaginationLink.new(href: "#") { "3" }
                    end
                    render Components::UI::PaginationItem.new do
                      render Components::UI::PaginationEllipsis.new
                    end
                    render Components::UI::PaginationItem.new do
                      render Components::UI::PaginationNext.new(href: "#")
                    end
                  end
                end
              RUBY
                render ::Components::UI::Pagination.new do
                  render ::Components::UI::PaginationContent.new do
                    render ::Components::UI::PaginationItem.new do
                      render ::Components::UI::PaginationPrevious.new(href: "#")
                    end
                    render ::Components::UI::PaginationItem.new do
                      render ::Components::UI::PaginationLink.new(href: "#") { "1" }
                    end
                    render ::Components::UI::PaginationItem.new do
                      render ::Components::UI::PaginationLink.new(href: "#", active: true) { "2" }
                    end
                    render ::Components::UI::PaginationItem.new do
                      render ::Components::UI::PaginationLink.new(href: "#") { "3" }
                    end
                    render ::Components::UI::PaginationItem.new do
                      render ::Components::UI::PaginationEllipsis.new
                    end
                    render ::Components::UI::PaginationItem.new do
                      render ::Components::UI::PaginationNext.new(href: "#")
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
                li { "Pagination renders a <nav> with aria-label=\"pagination\" so screen readers identify it as navigation." }
                li { "PaginationPrevious and PaginationNext include screen-reader-only text via sr-only spans." }
                li { "PaginationEllipsis includes a sr-only span announcing \"More pages\"." }
                li { "Active page link receives aria-current=\"page\" via the active: prop." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "pagination", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
