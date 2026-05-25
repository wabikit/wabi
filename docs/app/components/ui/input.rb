# frozen_string_literal: true

module Components
  module UI
    class Input < Wabi::Base
      variants do
        base "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 " \
             "text-sm ring-offset-background file:border-0 file:bg-transparent " \
             "file:text-sm file:font-medium placeholder:text-muted-foreground " \
             "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " \
             "focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
      end

      def initialize(type: "text", **attrs)
        @type  = type
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        input(type: @type, **@attrs, class: merge_class(tokens, user_class))
      end
    end
  end
end
