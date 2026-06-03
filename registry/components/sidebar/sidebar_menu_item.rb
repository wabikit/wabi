# frozen_string_literal: true

module Components
  module UI
    class SidebarMenuItem < Wabi::Base
      variants { base "relative" }

      def initialize(**attrs) = @attrs = attrs

      def view_template(&block)
        user_class = @attrs.delete(:class)
        li(**@attrs, class: merge_class(tokens, user_class)) { yield if block }
      end
    end
  end
end
