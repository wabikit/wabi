# frozen_string_literal: true

module Components
  module UI
    class SidebarMenuSub < Wabi::Base
      variants do
        base "ml-3.5 flex min-w-0 flex-col gap-1 border-l border-sidebar-border px-2.5 py-1 " \
             "group-data-[state=collapsed]/sidebar:hidden"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&block)
        user_class = @attrs.delete(:class)
        ul(**@attrs, class: merge_class(tokens, user_class)) { yield if block }
      end
    end
  end
end
