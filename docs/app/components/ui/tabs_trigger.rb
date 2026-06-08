# frozen_string_literal: true

require "date"

module Components
  module UI
    class TabsTrigger < Wabi::Base
      variants do
        base "inline-flex items-center justify-center whitespace-nowrap rounded-sm px-3 py-1.5 " \
             "text-sm font-medium transition-all motion-reduce:transition-none cursor-pointer focus-visible:outline-none " \
             "focus-visible:ring-2 focus-visible:ring-ring " \
             "aria-disabled:pointer-events-none aria-disabled:opacity-50 aria-disabled:cursor-not-allowed " \
             "aria-selected:bg-background aria-selected:text-foreground aria-selected:shadow-sm " \
             "group-data-[variant=pill]/tabs:rounded-full " \
             "group-data-[variant=pill]/tabs:text-muted-foreground " \
             "group-data-[variant=pill]/tabs:hover:text-foreground " \
             "group-data-[variant=pill]/tabs:aria-selected:bg-primary " \
             "group-data-[variant=pill]/tabs:aria-selected:text-primary-foreground " \
             "group-data-[variant=pill]/tabs:aria-selected:shadow-none " \
             "group-data-[variant=underline]/tabs:rounded-none " \
             "group-data-[variant=underline]/tabs:bg-transparent " \
             "group-data-[variant=underline]/tabs:shadow-none " \
             "group-data-[variant=underline]/tabs:border-b-[3px] " \
             "group-data-[variant=underline]/tabs:border-transparent " \
             "group-data-[variant=underline]/tabs:px-4 " \
             "group-data-[variant=underline]/tabs:py-3 " \
             "group-data-[variant=underline]/tabs:-mb-px " \
             "group-data-[variant=underline]/tabs:text-muted-foreground " \
             "group-data-[variant=underline]/tabs:hover:text-foreground " \
             "group-data-[variant=underline]/tabs:aria-selected:bg-transparent " \
             "group-data-[variant=underline]/tabs:aria-selected:shadow-none " \
             "group-data-[variant=underline]/tabs:aria-selected:border-b-primary " \
             "group-data-[variant=underline]/tabs:aria-selected:text-primary " \
             "group-data-[variant=underline]/tabs:aria-selected:font-bold"
      end

      def initialize(value:, disabled: false, **attrs)
        @value    = value
        @disabled = disabled
        @attrs    = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          type: "button",
          role: "tab",
          data: {
            "wabi--tabs-target": "trigger",
            "wabi-value": @value,
            "wabi-disabled": @disabled.to_s,
          },
          class: merge_class(tokens, user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
