# frozen_string_literal: true

module Components
  module UI
    class SidebarGroupLabel < Wabi::Base
      variants do
        base "flex h-8 shrink-0 items-center px-2 text-xs font-medium text-muted-foreground " \
             "transition-[opacity,height] duration-200 motion-reduce:transition-none " \
             "group-data-[state=collapsed]/sidebar:h-0 " \
             "group-data-[state=collapsed]/sidebar:opacity-0 " \
             "group-data-[state=collapsed]/sidebar:overflow-hidden"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(**@attrs, class: merge_class(tokens, user_class)) { yield if block }
      end
    end
  end
end
