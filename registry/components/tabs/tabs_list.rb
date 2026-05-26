# frozen_string_literal: true

require "date"

module Components
  module UI
    class TabsList < Wabi::Base
      variants do
        base "inline-flex h-10 items-center justify-center rounded-md bg-muted p-1 text-muted-foreground"
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
