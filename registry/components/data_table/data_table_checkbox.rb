# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    # Native, theme-styled checkbox for DataTable selection. NOT the Zag-backed
    # Checkbox — a plain <input> so a page of N rows doesn't spawn N machines and
    # the wabi--data-table controller can read/toggle them directly. `accent-primary`
    # themes the native check.
    class DataTableCheckbox < Wabi::Base
      variants do
        base "h-4 w-4 shrink-0 rounded-sm border border-primary accent-primary cursor-pointer " \
             "ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 " \
             "disabled:cursor-not-allowed disabled:opacity-50"
      end

      def initialize(select_all: false, value: nil, checked: false, row_label: nil, **attrs)
        @select_all = select_all
        @value      = value
        @checked    = checked
        @row_label  = row_label
        @attrs      = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        target = @select_all ? "selectAll" : "rowCheckbox"
        action = @select_all ? "change->wabi--data-table#toggleAll" : "change->wabi--data-table#toggleRow"
        # Per-row label uses row_label (display name) or falls back to value so
        # every checkbox has a unique accessible name — callers pass row_label: "Jane Doe"
        # or the value itself provides uniqueness when it is a human-readable ID.
        input(
          type: "checkbox",
          value: @value,
          checked: @checked,
          "aria-label": (@select_all ? "Select all rows" : "Select row #{@row_label || @value}"),
          data: { "wabi--data-table-target": target, action: action },
          **@attrs,
          class: merge_class(tokens, user_class)
        )
      end
    end
  end
end
