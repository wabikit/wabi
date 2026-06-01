# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Table < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/table.rb
          app/components/ui/table_header.rb
          app/components/ui/table_body.rb
          app/components/ui/table_footer.rb
          app/components/ui/table_row.rb
          app/components/ui/table_head.rb
          app/components/ui/table_cell.rb
          app/components/ui/table_caption.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Table", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Table" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add table",
                language: "shell"
              )

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Table.new do
                  render Components::UI::TableCaption.new { "A list of your recent invoices." }
                  render Components::UI::TableHeader.new do
                    render Components::UI::TableRow.new do
                      render Components::UI::TableHead.new { "Invoice" }
                      render Components::UI::TableHead.new { "Status" }
                      render Components::UI::TableHead.new(class: "text-right") { "Amount" }
                    end
                  end
                  render Components::UI::TableBody.new do
                    render Components::UI::TableRow.new do
                      render Components::UI::TableCell.new(class: "font-medium") { "INV001" }
                      render Components::UI::TableCell.new { "Paid" }
                      render Components::UI::TableCell.new(class: "text-right") { "$250.00" }
                    end
                    render Components::UI::TableRow.new do
                      render Components::UI::TableCell.new(class: "font-medium") { "INV002" }
                      render Components::UI::TableCell.new { "Pending" }
                      render Components::UI::TableCell.new(class: "text-right") { "$150.00" }
                    end
                  end
                end
              RUBY
                render ::Components::UI::Table.new do
                  render ::Components::UI::TableCaption.new { "A list of your recent invoices." }
                  render ::Components::UI::TableHeader.new do
                    render ::Components::UI::TableRow.new do
                      render ::Components::UI::TableHead.new { "Invoice" }
                      render ::Components::UI::TableHead.new { "Status" }
                      render ::Components::UI::TableHead.new(class: "text-right") { "Amount" }
                    end
                  end
                  render ::Components::UI::TableBody.new do
                    render ::Components::UI::TableRow.new do
                      render ::Components::UI::TableCell.new(class: "font-medium") { "INV001" }
                      render ::Components::UI::TableCell.new { "Paid" }
                      render ::Components::UI::TableCell.new(class: "text-right") { "$250.00" }
                    end
                    render ::Components::UI::TableRow.new do
                      render ::Components::UI::TableCell.new(class: "font-medium") { "INV002" }
                      render ::Components::UI::TableCell.new { "Pending" }
                      render ::Components::UI::TableCell.new(class: "text-right") { "$150.00" }
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
                li { "Uses native table elements (table/thead/tbody/tfoot/tr/th/td/caption), so screen readers get the table semantics for free." }
                li { "TableHead renders a th; add scope: \"col\" / scope: \"row\" via attrs when the header relationship isn't obvious." }
                li { "TableCaption gives the table an accessible name — prefer it over a separate heading." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "table", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
