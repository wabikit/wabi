# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class HoverCardTrigger < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          type: "button",
          # aria-haspopup signals to AT that this trigger opens a popup panel.
          # Zag never supplies this attribute via getTriggerProps(), so we set
          # it statically here. Callers may override via attrs if needed.
          "aria-haspopup": "true",
          **@attrs,
          data: { "wabi--hover-card-target": "trigger" },
          class: merge_class("inline-flex items-center underline-offset-4 hover:underline cursor-pointer", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
