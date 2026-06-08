# frozen_string_literal: true

module Components
  module UI
    class Textarea < Wabi::Base
      variants do
        base "flex min-h-[80px] w-full rounded-md border border-input bg-background " \
             "px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground " \
             "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " \
             "focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
      end

      # Callers are responsible for label association (WCAG 1.3.1 / 4.1.2).
      # Pass `id:` and pair with `<label for="...">`, or supply `aria_label:` /
      # `aria_labelledby:` via attrs when no visible label is present.
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&)
        user_class = @attrs.delete(:class)
        textarea(**@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
