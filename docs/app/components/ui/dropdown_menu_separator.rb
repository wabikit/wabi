# frozen_string_literal: true

require "date"

module Components
  module UI
    class DropdownMenuSeparator < Wabi::Base
      variants { base "-mx-1 my-1 h-px bg-muted" }

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        div(role: "separator", class: merge_class(tokens, user_class))
      end
    end
  end
end
