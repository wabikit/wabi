# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class ComboboxLoading < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        # Always present in the DOM so the aria-live region is registered with
        # the accessibility tree at page load. Visually hidden (sr-only) when
        # inactive; the controller removes that class to reveal content.
        div(
          "aria-live": "polite",
          "aria-atomic": "true",
          data: { "wabi--combobox-target": "loading" },
          class: merge_class("sr-only px-2 py-1.5 text-sm text-muted-foreground", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
