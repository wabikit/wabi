# frozen_string_literal: true

module Components
  module UI
    class Badge < Wabi::Base
      variants do
        base "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs " \
             "font-semibold transition-colors motion-reduce:transition-none focus:outline-none focus:ring-2 " \
             "focus:ring-ring focus:ring-offset-2"

        variant :appearance, {
          primary:     "border-transparent bg-primary text-primary-foreground hover:bg-primary/80",
          secondary:   "border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80",
          destructive: "border-transparent bg-destructive text-destructive-foreground hover:bg-destructive/80",
          outline:     "text-foreground"
        }, default: :primary
      end

      def initialize(appearance: nil, **attrs)
        @appearance = appearance
        @attrs      = attrs
      end

      def view_template(&)
        user_class = @attrs.delete(:class)
        div(**@attrs, class: merge_class(tokens(appearance: @appearance), user_class), &)
      end
    end
  end
end
