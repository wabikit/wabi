# frozen_string_literal: true

module Components
  module UI
    class Alert < Wabi::Base
      variants do
        base "relative w-full rounded-lg border p-4 " \
             "[&>svg~*]:pl-7 [&>svg+div]:translate-y-[-3px] " \
             "[&>svg]:absolute [&>svg]:left-4 [&>svg]:top-4 [&>svg]:text-foreground"

        variant :appearance, {
          default:     "bg-background text-foreground",
          destructive: "border-destructive/50 text-destructive [&>svg]:text-destructive"
        }, default: :default
      end

      def initialize(appearance: nil, **attrs)
        @appearance = appearance
        @attrs      = attrs
      end

      def view_template(&)
        user_class = @attrs.delete(:class)
        div(
          role: "alert",
          **@attrs,
          class: merge_class(tokens(appearance: @appearance), user_class),
          &
        )
      end
    end
  end
end
