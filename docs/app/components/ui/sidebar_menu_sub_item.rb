# frozen_string_literal: true

module Components
  module UI
    class SidebarMenuSubItem < Wabi::Base
      variants do
        base "relative"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&block)
        user_class = @attrs.delete(:class)
        li(**@attrs, class: merge_class(tokens, user_class)) { yield if block }
      end
    end
  end
end
