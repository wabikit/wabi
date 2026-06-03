# frozen_string_literal: true

module Components
  module UI
    class Sidebar < Wabi::Base
      BASE = "flex flex-col bg-background text-foreground overflow-hidden " \
             "fixed inset-y-0 z-50 w-64 transition-transform duration-200 ease-in-out " \
             "group-data-[mobile=open]/sidebar:translate-x-0 " \
             "lg:sticky lg:top-0 lg:z-auto lg:h-svh lg:translate-x-0 lg:transition-[width] " \
             "lg:w-64 group-data-[state=collapsed]/sidebar:lg:w-[3.25rem]"

      SIDE = {
        left:  "left-0 border-r border-border -translate-x-full",
        right: "right-0 border-l border-border translate-x-full",
      }.freeze

      def initialize(side: :left, **attrs)
        @side  = side
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        aside(
          **@attrs,
          data: { "wabi--sidebar-target": "panel" },
          tabindex: -1,
          class: merge_class(BASE, SIDE.fetch(@side, SIDE[:left]), user_class)
        ) do
          yield if block
        end
      end
    end
  end
end
