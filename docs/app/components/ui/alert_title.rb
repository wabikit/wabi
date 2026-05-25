# frozen_string_literal: true

module Components
  module UI
    class AlertTitle < Wabi::Base
      variants { base "mb-1 font-medium leading-none tracking-tight" }

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        h5(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
