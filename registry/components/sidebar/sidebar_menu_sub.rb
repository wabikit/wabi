# frozen_string_literal: true

module Components
  module UI
    class SidebarMenuSub < Wabi::Base
      variants do
        base "ml-3.5 flex min-w-0 flex-col gap-1 border-l border-sidebar-border px-2.5 py-1 " \
             "group-data-[state=collapsed]/sidebar:hidden " \
             "data-[flyout=open]:!flex data-[flyout=open]:!fixed data-[flyout=open]:z-50 " \
             "data-[flyout=open]:min-w-48 data-[flyout=open]:ml-0 data-[flyout=open]:border-l-0 " \
             "data-[flyout=open]:rounded-md data-[flyout=open]:border data-[flyout=open]:border-sidebar-border " \
             "data-[flyout=open]:bg-sidebar data-[flyout=open]:p-1 data-[flyout=open]:shadow-lg"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&block)
        user_class = @attrs.delete(:class)
        ul(**@attrs, class: merge_class(tokens, user_class)) { yield if block }
      end
    end
  end
end
