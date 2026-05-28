# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class CommandTrigger < Wabi::Base
      TRIGGER_CLASS = "inline-flex items-center justify-between h-10 px-4 rounded-md " \
                      "border border-input bg-background text-sm text-muted-foreground " \
                      "hover:bg-accent hover:text-accent-foreground transition-colors"

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          **@attrs,
          type: "button",
          data: { "wabi--dialog-target": "trigger" },
          class: merge_class(TRIGGER_CLASS, user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
