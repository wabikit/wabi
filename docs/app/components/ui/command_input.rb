# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class CommandInput < Wabi::Base
      INPUT_CLASS = "flex h-12 w-full bg-transparent py-3 px-4 text-sm outline-none " \
                    "placeholder:text-muted-foreground border-b border-input"

      def initialize(placeholder: "Type a command or search...", **attrs)
        @placeholder = placeholder
        @attrs       = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        input(
          **@attrs,
          type: "text",
          placeholder: @placeholder,
          data: { "wabi--combobox-target": "input" },
          class: merge_class(INPUT_CLASS, user_class)
        )
      end
    end
  end
end
