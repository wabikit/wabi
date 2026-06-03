# frozen_string_literal: true

module Components
  module UI
    class SidebarContent < Wabi::Base
      variants { base "flex flex-1 min-h-0 flex-col gap-2 overflow-auto p-2" }

      def initialize(**attrs) = @attrs = attrs

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(**@attrs, class: merge_class(tokens, user_class)) { yield if block }
      end
    end
  end
end
