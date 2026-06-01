# frozen_string_literal: true

require "wabi"
require_relative "table"
require_relative "table_header"
require_relative "table_body"
require_relative "table_footer"
require_relative "table_row"
require_relative "table_head"
require_relative "table_cell"
require_relative "table_caption"

RSpec.describe Components::UI::Table do
  it "renders a table wrapped in an overflow-auto container" do
    output = described_class.new.call
    expect(output).to include("relative w-full overflow-auto")
    expect(output).to include("<table")
    expect(output).to include("caption-bottom")
    expect(output).to include("text-sm")
  end

  it "merges a user class onto the table instead of replacing the base" do
    output = described_class.new(class: "my-8").call
    expect(output).to include("my-8")
    expect(output).to include("caption-bottom")
  end

  it "renders TableHeader as thead with bottom-border rows" do
    output = Components::UI::TableHeader.new.call { "x" }
    expect(output).to include("<thead")
    expect(output).to include("[&_tr]:border-b")
  end

  it "renders TableBody as tbody" do
    output = Components::UI::TableBody.new.call { "x" }
    expect(output).to include("<tbody")
    expect(output).to include("[&_tr:last-child]:border-0")
  end

  it "renders TableFooter as tfoot with a muted background" do
    output = Components::UI::TableFooter.new.call { "x" }
    expect(output).to include("<tfoot")
    expect(output).to include("bg-muted/50")
  end

  it "renders TableRow as tr with hover + selected states" do
    output = Components::UI::TableRow.new.call { "x" }
    expect(output).to include("<tr")
    expect(output).to include("hover:bg-muted/50")
    expect(output).to include("data-[state=selected]:bg-muted")
  end

  it "renders TableHead as a left-aligned muted th" do
    output = Components::UI::TableHead.new.call { "Name" }
    expect(output).to include("<th")
    expect(output).to include("text-left")
    expect(output).to include("text-muted-foreground")
    expect(output).to include(">Name</th>")
  end

  it "renders TableCell as td" do
    output = Components::UI::TableCell.new.call { "Acme" }
    expect(output).to include("<td")
    expect(output).to include("align-middle")
    expect(output).to include(">Acme</td>")
  end

  it "renders TableCaption as caption" do
    output = Components::UI::TableCaption.new.call { "A list of invoices." }
    expect(output).to include("<caption")
    expect(output).to include("text-muted-foreground")
    expect(output).to include(">A list of invoices.</caption>")
  end

  it "composes a full table" do
    composition = Class.new(Phlex::HTML) do
      def view_template
        render Components::UI::Table.new do
          render Components::UI::TableCaption.new { "Invoices" }
          render Components::UI::TableHeader.new do
            render Components::UI::TableRow.new do
              render Components::UI::TableHead.new { "Invoice" }
              render Components::UI::TableHead.new { "Amount" }
            end
          end
          render Components::UI::TableBody.new do
            render Components::UI::TableRow.new do
              render Components::UI::TableCell.new { "INV001" }
              render Components::UI::TableCell.new { "$250.00" }
            end
          end
        end
      end
    end

    output = composition.new.call
    expect(output).to include("Invoices")
    expect(output).to include("INV001")
    expect(output).to include("$250.00")
    expect(output).to include("Invoice")
  end
end
