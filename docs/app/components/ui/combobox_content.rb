# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class ComboboxContent < Wabi::Base
      variants do
        base "z-50 max-h-96 min-w-[8rem] overflow-y-auto rounded-md border border-input " \
             "bg-popover text-popover-foreground shadow-md p-1 " \
             "transition-opacity duration-150 ease-out motion-reduce:transition-none " \
             "data-[state=open]:opacity-100 data-[state=closed]:opacity-0 " \
             "data-[state=closed]:pointer-events-none list-none m-0"
      end

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        ul(
          data: { "wabi--combobox-target": "content" },
          "data-state": "closed",
          inert: true,
          class: merge_class(tokens, user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
