# frozen_string_literal: true

module Components
  module UI
    class SidebarMenu < Wabi::Base
      variants { base "flex w-full min-w-0 flex-col gap-1" }

      def initialize(**attrs) = @attrs = attrs

      def view_template(&block)
        user_class = @attrs.delete(:class)
        ul(**@attrs, class: merge_class(tokens, user_class)) { yield if block }
      end
    end
  end
end
