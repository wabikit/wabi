# frozen_string_literal: true

require "date"

module Components
  module UI
    class SelectTrigger < Wabi::Base
      variants do
        base "flex h-10 w-full items-center justify-between rounded-md border border-input " \
             "bg-background px-3 py-2 text-sm ring-offset-background " \
             "placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " \
             "focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
      end

      def initialize(aria_label: nil, **attrs)
        @aria_label = aria_label
        @attrs      = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          type: "button",
          # OPTIONAL accessible name for the combobox trigger. The button's only
          # child is SelectValue, which is empty until a value is chosen, so axe
          # (button-name) flags it as unnamed. Set aria_label: to fix it.
          "aria-label": @aria_label,
          data: { "wabi--select-target": "trigger" },
          class: merge_class(tokens, user_class)
        ) do
          yield if block_given?
          span(
            "aria-hidden": "true",
            data: { "wabi--select-target": "indicator" },
            class: "ml-2 h-4 w-4 opacity-50"
          ) do
            raw(safe('<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>'))
          end
        end
      end
    end
  end
end
