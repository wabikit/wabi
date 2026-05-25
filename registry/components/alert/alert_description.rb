# frozen_string_literal: true

module Components
  module UI
    class AlertDescription < Wabi::Base
      variants { base "text-sm [&_p]:leading-relaxed" }

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        div(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
