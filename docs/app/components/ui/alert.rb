# frozen_string_literal: true

module Components
  module UI
    class Alert < Wabi::Base
      # Consumer note: if you pass a decorative SVG icon as a direct child,
      # add aria-hidden="true" and focusable="false" to that SVG element so
      # screen readers skip the unlabelled graphic (e.g. <svg aria-hidden="true" focusable="false" ...>).
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

      # Live-region note: role="alert" (an implicit aria-live="assertive" region) only
      # fires a screen-reader announcement when the element is *injected into the DOM
      # after page load*. A statically server-rendered Alert that is present in the
      # initial HTML is silently ignored by NVDA, JAWS, and VoiceOver.
      # To announce dynamic alerts, inject the element via Turbo Stream or a Stimulus
      # controller that appends it at runtime (do NOT rely on toggling visibility).
      def view_template(&)
        user_class = @attrs.delete(:class)
        div(
          role: "alert",
          "aria-atomic": "true",
          **@attrs,
          class: merge_class(tokens(appearance: @appearance), user_class),
          &
        )
      end
    end
  end
end
