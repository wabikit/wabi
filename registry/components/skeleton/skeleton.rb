# frozen_string_literal: true

module Components
  module UI
    class Skeleton < Wabi::Base
      variants do
        base "animate-pulse motion-reduce:animate-none rounded-md bg-muted"
      end

      def initialize(**attrs) = @attrs = attrs

      def view_template(&)
        user_class = @attrs.delete(:class)
        # aria-busy signals loading state to AT; aria-label provides a default description.
        # Callers can override either via **attrs (e.g. aria_label: "Loading avatar").
        # The parent container or the content that replaces this skeleton should carry
        # role="status" or aria-live="polite" so AT announces when loading completes.
        div(
          "aria-busy": "true",
          "aria-label": "Loading…",
          **@attrs,
          class: merge_class(tokens, user_class),
          &
        )
      end
    end
  end
end
