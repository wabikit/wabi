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

  # WCAG-AA (live-regions): a visually-hidden role=status span must be present so
  # screen readers announce row-selection changes without requiring the caller to add one.
  it "includes a sr-only role=status live region wired to the statusAnnouncer target" do
    output = described_class.new.call { "x" }
    expect(output).to include('role="status"')
    expect(output).to include('class="sr-only"')
    expect(output).to include('data-wabi--data-table-target="statusAnnouncer"')
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

    # WCAG-AA: each row checkbox must have a unique accessible name so screen
    # reader users can distinguish rows (names-labels finding, data_table_checkbox.rb:33)
    it "falls back to value in the aria-label so every row checkbox is uniquely named" do
      output = described_class.new(value: "99").call
      expect(output).to include('aria-label="Select row 99"')
    end

    it "uses row_label in aria-label when provided, giving a human-readable name" do
      output = described_class.new(value: "1", row_label: "Jane Doe").call
      expect(output).to include('aria-label="Select row Jane Doe"')
    end

    it "row_label is optional — omitting it does not break existing call sites" do
      expect { described_class.new(value: "5").call }.not_to raise_error
    end
  end
end
