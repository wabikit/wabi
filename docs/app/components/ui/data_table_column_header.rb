# frozen_string_literal: true

module Components
  module UI
    # Sortable column header — a plain link the server acts on. Place inside a
    # TableHead. `sorted:` is this column's current state (nil / :asc / :desc);
    # `href:` is the app-computed toggle target. No JS.
    class DataTableColumnHeader < Wabi::Base
      variants do
        base "inline-flex items-center gap-1 transition-colors hover:text-foreground"
      end

      ICONS = {
        asc:  '<svg aria-hidden="true" focusable="false" class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="18 15 12 9 6 15"/></svg>',
        desc: '<svg aria-hidden="true" focusable="false" class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>',
        none: '<svg aria-hidden="true" focusable="false" class="h-3.5 w-3.5 opacity-50" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="8 9 12 5 16 9"/><polyline points="16 15 12 19 8 15"/></svg>',
      }.freeze

      # Sort direction announced to assistive tech (the icon is decorative). For the
      # full ARIA pattern also set aria-sort ("ascending"/"descending") on the
      # wrapping <th> (TableHead) — pass it from the same `sorted` state.
      SR_LABEL = { asc: ", sorted ascending", desc: ", sorted descending" }.freeze

      def initialize(href:, sorted: nil, **attrs)
        @href   = href
        @sorted = sorted
        @attrs  = attrs
      end

      def view_template(&)
        user_class = @attrs.delete(:class)
        a(href: @href, **@attrs, class: merge_class(tokens, user_class)) do
          yield
          raw(safe(ICONS[@sorted || :none]))
          span(class: "sr-only") { SR_LABEL[@sorted] } if SR_LABEL.key?(@sorted)
        end
      end
    end
  end
end
