# frozen_string_literal: true

require_relative "pagination_link"

module Components
  module UI
    class PaginationPrevious < Wabi::Base
      def initialize(**attrs) = @attrs = attrs

      def view_template
        user_class = @attrs.delete(:class)
        render Components::UI::PaginationLink.new(
          "aria-label": "Go to previous page",
          **@attrs,
          class: merge_class("gap-1 w-auto pl-2.5", user_class)
        ) do
          raw(safe('<svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>'))
          span { "Previous" }
        end
      end
    end
  end
end
