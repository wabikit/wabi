# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class ComboboxInput < Wabi::Base
      INPUT_CLASS = "flex h-10 w-full rounded-md border border-input bg-background " \
                    "px-3 py-2 text-sm ring-offset-background " \
                    "placeholder:text-muted-foreground " \
                    "focus-visible:outline-none focus-visible:ring-2 " \
                    "focus-visible:ring-ring focus-visible:ring-offset-2 " \
                    "disabled:cursor-not-allowed disabled:opacity-50"

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        input(
          type: "text",
          data: { "wabi--combobox-target": "input" },
          class: merge_class(INPUT_CLASS, user_class)
        )
      end
    end
  end
end
