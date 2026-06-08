# frozen_string_literal: true

module Components
  module UI
    class TableRow < Wabi::Base
      variants do
        base "border-b transition-colors motion-reduce:transition-none hover:bg-muted/50 data-[state=selected]:bg-muted"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        # Reflect selection state programmatically so AT users know when a row
        # is selected (data-state="selected" drives the visual via Tailwind;
        # aria-selected carries the same signal to screen readers).
        # Callers mark rows with data-state: "selected"; parent containers
        # should carry role="grid" or rows role="row" per ARIA grid pattern.
        aria_selected = @attrs[:'data-state'] == "selected" ? "true" : nil
        tr(aria_selected: aria_selected, **@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
