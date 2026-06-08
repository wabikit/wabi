# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    # Scope wrapper that hosts the wabi--data-table selection controller.
    # Compose: DataTable { Table { … DataTableColumnHeader / DataTableCheckbox … } + Pagination }.
    class DataTable < Wabi::Base
      def initialize(**attrs) = @attrs = attrs

      def view_template
        user_class = @attrs.delete(:class)
        div(data: { controller: "wabi--data-table" }, **@attrs, class: user_class) do
          yield if block_given?
          # Live region announces row-selection changes to screen reader users (WCAG 4.1.3).
          span(
            role: "status",
            class: "sr-only",
            data: { "wabi--data-table-target": "statusAnnouncer" }
          )
        end
      end
    end
  end
end
