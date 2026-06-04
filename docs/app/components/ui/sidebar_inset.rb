# frozen_string_literal: true

module Components
  module UI
    class SidebarInset < Wabi::Base
      variants do
        base "flex grow flex-col min-w-0 " \
             "group-data-[variant=inset]/sidebar:m-2 " \
             "group-data-[variant=inset]/sidebar:rounded-xl " \
             "group-data-[variant=inset]/sidebar:border " \
             "group-data-[variant=inset]/sidebar:border-sidebar-border " \
             "group-data-[variant=inset]/sidebar:bg-background " \
             "group-data-[variant=inset]/sidebar:shadow-sm"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&block)
        user_class = @attrs.delete(:class)
        main(**@attrs, class: merge_class(tokens, user_class)) { yield if block }
      end
    end
  end
end
