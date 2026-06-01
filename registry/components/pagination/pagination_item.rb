# frozen_string_literal: true

module Components
  module UI
    class PaginationItem < Wabi::Base
      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        li(**@attrs, class: user_class, &)
      end
    end
  end
end
