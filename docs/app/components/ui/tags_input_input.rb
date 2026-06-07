# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class TagsInputInput < Wabi::Base
      def initialize(placeholder: nil, **attrs)
        @placeholder = placeholder
        @attrs       = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        input(
          type: "text",
          placeholder: @placeholder,
          data: { "wabi--tags-input-target": "input" },
          class: merge_class(
            "flex-1 min-w-[6rem] bg-transparent outline-none placeholder:text-muted-foreground " \
            "disabled:cursor-not-allowed",
            user_class
          )
        )
      end
    end
  end
end
