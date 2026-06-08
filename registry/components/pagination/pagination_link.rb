# frozen_string_literal: true

module Components
  module UI
    class PaginationLink < Wabi::Base
      variants do
        base "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors motion-reduce:transition-none focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring h-10 w-10"

        variant :state, {
          active:   "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
          inactive: "hover:bg-accent hover:text-accent-foreground",
        }, default: :inactive
      end

      def initialize(active: false, **attrs)
        @active = active
        @attrs  = attrs
      end

      def view_template(&)
        user_class = @attrs.delete(:class)
        state = @active ? :active : :inactive
        a(
          **(@active ? { "aria-current": "page" } : {}),
          **@attrs,
          class: merge_class(tokens(state: state), user_class),
          &
        )
      end
    end
  end
end
