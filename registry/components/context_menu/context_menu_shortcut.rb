# frozen_string_literal: true

require "date"

module Components
  module UI
    # Cosmetic helper for displaying a keyboard shortcut at the right edge of a
    # menu item. The shortcut is purely visual -- wiring the actual keypress
    # handler is the caller's responsibility (Stimulus action or Hotkey lib).
    class ContextMenuShortcut < Wabi::Base
      variants { base "ml-auto text-xs tracking-widest text-muted-foreground" }

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        span(aria: { hidden: "true" }, class: merge_class(tokens, user_class)) do
          yield if block_given?
        end
      end
    end
  end
end
