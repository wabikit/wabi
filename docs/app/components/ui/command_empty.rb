# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class CommandEmpty < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          **@attrs,
          role: "status",
          data: { "wabi-command-empty": "true" },
          class: merge_class("py-6 text-center text-sm text-muted-foreground", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
