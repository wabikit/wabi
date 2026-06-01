# frozen_string_literal: true

module Components
  module UI
    class Breadcrumb < Wabi::Base
      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        nav("aria-label": "breadcrumb", **@attrs, class: user_class, &)
      end
    end
  end
end
