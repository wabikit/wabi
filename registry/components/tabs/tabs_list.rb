# frozen_string_literal: true

require "date"

module Components
  module UI
    class TabsList < Wabi::Base
      variants do
        base "inline-flex h-10 items-center justify-center rounded-md bg-muted p-1 text-muted-foreground " \
             "group-data-[variant=pill]/tabs:rounded-full " \
             "group-data-[variant=pill]/tabs:gap-1 " \
             "group-data-[variant=pill]/tabs:border " \
             "group-data-[variant=pill]/tabs:border-border " \
             "group-data-[variant=pill]/tabs:bg-muted/40 " \
             "group-data-[variant=underline]/tabs:w-full " \
             "group-data-[variant=underline]/tabs:justify-start " \
             "group-data-[variant=underline]/tabs:gap-4 " \
             "group-data-[variant=underline]/tabs:rounded-none " \
             "group-data-[variant=underline]/tabs:bg-transparent " \
             "group-data-[variant=underline]/tabs:border-b " \
             "group-data-[variant=underline]/tabs:border-border " \
             "group-data-[variant=underline]/tabs:px-4 " \
             "group-data-[variant=underline]/tabs:py-0 " \
             "group-data-[variant=underline]/tabs:h-auto"
      end

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          role: "tablist",
          data: { "wabi--tabs-target": "list" },
          class: merge_class(tokens, user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
