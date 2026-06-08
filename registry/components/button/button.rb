# frozen_string_literal: true

module Components
  module UI
    class Button < Wabi::Base
      variants do
        base "inline-flex items-center justify-center rounded-md text-sm font-medium " \
             "transition-colors motion-reduce:transition-none focus-visible:outline-none focus-visible:ring-2 " \
             "focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50"

        variant :appearance, {
          primary:     "bg-primary text-primary-foreground hover:bg-primary/90",
          secondary:   "bg-secondary text-secondary-foreground hover:bg-secondary/80",
          destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
          outline:     "border border-primary bg-background text-primary hover:bg-accent hover:text-accent-foreground",
          ghost:       "hover:bg-accent hover:text-accent-foreground",
          link:        "text-primary underline-offset-4 hover:underline"
        }, default: :primary

        variant :size, {
          sm:   "h-9 px-3",
          md:   "h-10 px-4 py-2",
          lg:   "h-11 px-8",
          icon: "h-10 w-10"
        }, default: :md
      end

      def initialize(appearance: nil, size: nil, **attrs)
        @appearance = appearance
        @size       = size
        @attrs      = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          **@attrs,
          class: merge_class(tokens(appearance: @appearance, size: @size), user_class),
          &block
        )
      end
    end
  end
end
