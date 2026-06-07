# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class TagsInputControl < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--tags-input-target": "control" },
          class: merge_class(
            "flex min-h-10 w-full flex-wrap items-center gap-1.5 rounded-md border border-input " \
            "bg-background px-3 py-2 text-sm ring-offset-background " \
            "focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2 " \
            "data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50",
            user_class
          )
        ) do
          yield if block_given?
        end
      end
    end
  end
end
