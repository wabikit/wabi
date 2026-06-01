# frozen_string_literal: true

require "wabi"
require_relative "data_table"
require_relative "data_table_column_header"
require_relative "data_table_checkbox"

RSpec.describe Components::UI::DataTable do
  it "wraps content in a wabi--data-table controller scope" do
    output = described_class.new.call { "x" }
    expect(output).to include("<div")
    expect(output).to include('data-controller="wabi--data-table"')
  end

  describe Components::UI::DataTableColumnHeader do
    it "renders a sort link with the label and a neutral indicator when unsorted" do
      output = described_class.new(href: "?sort=name&direction=asc").call { "Name" }
      expect(output).to include("<a")
      expect(output).to include('href="?sort=name&direction=asc"')
      expect(output).to include("Name")
      expect(output).to include("<svg")
    end

    it "shows the ascending chevron when sorted asc" do
      output = described_class.new(href: "#", sorted: :asc).call { "Name" }
      expect(output).to include("18 15 12 9 6 15")
    end

    it "shows the descending chevron when sorted desc" do
      output = described_class.new(href: "#", sorted: :desc).call { "Name" }
      expect(output).to include("6 9 12 15 18 9")
    end
  end

  describe Components::UI::DataTableCheckbox do
    it "renders a native select-all checkbox wired to toggleAll" do
      output = described_class.new(select_all: true).call
      expect(output).to include('type="checkbox"')
      expect(output).to include('data-wabi--data-table-target="selectAll"')
      expect(output).to include("change->wabi--data-table#toggleAll")
      expect(output).to include('aria-label="Select all rows"')
    end

    it "renders a row checkbox carrying its value, wired to toggleRow" do
      output = described_class.new(value: "42").call
      expect(output).to include('data-wabi--data-table-target="rowCheckbox"')
      expect(output).to include('value="42"')
      expect(output).to include("change->wabi--data-table#toggleRow")
    end
  end
end
