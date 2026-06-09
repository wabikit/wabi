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
        # role="status" is a live region that legitimately supports an accessible name,
        # so aria-label is valid here (a bare <div> is role=generic and prohibits it) and
        # AT announces the loading state. aria-busy signals loading; aria-label describes it.
        # Callers can override any of these via **attrs (e.g. aria_label: "Loading avatar").
        div(
          role: "status",
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
