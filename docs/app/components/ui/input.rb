# frozen_string_literal: true

module Components
  module UI
    # Accessibility: an <input> needs an accessible name. This primitive forwards
    # all attrs, so callers MUST supply one of: an associated <label for=> (pass a
    # matching `id:`), a wrapping <label>, or `aria_label:` / `aria-label:` directly.
    # A bare Input with none of these is an unlabelled control (WCAG 4.1.2 fail).
    class Input < Wabi::Base
      variants do
        base "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 " \
             "text-sm ring-offset-background file:border-0 file:bg-transparent " \
             "file:text-sm file:font-medium placeholder:text-muted-foreground " \
             "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " \
             "focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 " \
             "aria-[invalid=true]:border-destructive aria-[invalid=true]:focus-visible:ring-destructive"
      end

      def initialize(type: "text", invalid: false, **attrs)
        @type    = type
        @invalid = invalid
        @attrs   = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        input(
          type: @type,
          aria_invalid: (@invalid ? "true" : nil),
          **@attrs,
          class: merge_class(tokens, user_class)
        )
      end
    end
  end
end
