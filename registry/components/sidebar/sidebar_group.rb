# frozen_string_literal: true

module Components
  module UI
    class SidebarGroup < Wabi::Base
      variants { base "relative flex w-full min-w-0 flex-col p-2" }

      def initialize(**attrs) = @attrs = attrs

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(**@attrs, class: merge_class(tokens, user_class)) { yield if block }
      end
    end
  end
end
