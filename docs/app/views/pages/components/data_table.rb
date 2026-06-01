# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class DataTable < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/data_table.rb
          app/components/ui/data_table_column_header.rb
          app/components/ui/data_table_checkbox.rb
          app/javascript/controllers/wabi/data_table_controller.js
        ].freeze

        ROWS = [
          { id: "INV001", name: "Acme Co.",   status: "Paid",    amount: 250 },
          { id: "INV002", name: "Globex",     status: "Pending", amount: 150 },
          { id: "INV003", name: "Initech",    status: "Paid",    amount: 350 },
          { id: "INV004", name: "Umbrella",   status: "Overdue", amount:  90 },
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Data Table", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Data Table" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(source: "bin/rails g wabi:add data_table", language: "shell")

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              p(class: "text-sm text-muted-foreground mb-4") do
                "Click a column header to sort (server-driven via Turbo); use the checkboxes to select rows."
              end
              render_demo

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}", class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "Sortable headers are real links — keyboard-focusable and announced as links; set aria-sort on the surrounding TableHead in your app if you want the sort state announced." }
                li { "Selection checkboxes are native inputs with aria-label; the select-all reflects an indeterminate state when only some rows are checked." }
                li { "Selected rows get data-state=\"selected\" (TableRow styles it); the wabi--data-table:change event carries the selected values for bulk actions." }
              end
            end
          end
        end

        private

        def render_demo
          sort = helpers.params[:sort]
          dir  = helpers.params[:direction] == "desc" ? "desc" : "asc"
          rows = ROWS.dup
          if sort && ROWS.first.key?(sort.to_sym)
            rows = rows.sort_by { |r| r[sort.to_sym] }
            rows = rows.reverse if dir == "desc"
          end

          render ::Components::UI::DataTable.new do
            render ::Components::UI::Table.new do
              render ::Components::UI::TableHeader.new do
                render ::Components::UI::TableRow.new do
                  render ::Components::UI::TableHead.new(class: "w-10") do
                    render ::Components::UI::DataTableCheckbox.new(select_all: true)
                  end
                  render ::Components::UI::TableHead.new do
                    render ::Components::UI::DataTableColumnHeader.new(href: sort_href("name", sort, dir), sorted: state_for("name", sort, dir)) { "Customer" }
                  end
                  render ::Components::UI::TableHead.new { "Status" }
                  render ::Components::UI::TableHead.new(class: "text-right") do
                    render ::Components::UI::DataTableColumnHeader.new(href: sort_href("amount", sort, dir), sorted: state_for("amount", sort, dir)) { "Amount" }
                  end
                end
              end
              render ::Components::UI::TableBody.new do
                rows.each do |row|
                  render ::Components::UI::TableRow.new do
                    render ::Components::UI::TableCell.new do
                      render ::Components::UI::DataTableCheckbox.new(value: row[:id])
                    end
                    render ::Components::UI::TableCell.new(class: "font-medium") { row[:name] }
                    render ::Components::UI::TableCell.new { row[:status] }
                    render ::Components::UI::TableCell.new(class: "text-right") { "$%.2f" % row[:amount] }
                  end
                end
              end
            end
          end
        end

        def sort_href(key, sort, dir)
          next_dir = (sort == key && dir == "asc") ? "desc" : "asc"
          "/docs/components/data_table?sort=#{key}&direction=#{next_dir}"
        end

        def state_for(key, sort, dir)
          return nil unless sort == key
          dir.to_sym
        end

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "data_table", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
