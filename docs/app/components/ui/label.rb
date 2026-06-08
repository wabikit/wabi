# frozen_string_literal: true

module Components
  module UI
    # Renders a <label> element with typography tokens applied.
    #
    # ACCESSIBILITY: callers MUST associate this label with a control in one of
    # two ways:
    #   1. Pass `for_: <input-id>` to emit a `for` attribute linking to the
    #      input's id (the input must have a matching `id:` attribute).
    #   2. Physically wrap the control as a block child so the label implicitly
    #      owns it:  render Label.new { render Input.new }
    #
    # Rendering a <label> with neither for_ nor a wrapped control produces a
    # label that is not programmatically associated with any input, which
    # violates WCAG 1.3.1 Info and Relationships (Level A).
    class Label < Wabi::Base
      variants do
        base "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      end

      def initialize(for_: nil, **attrs)
        @for_  = for_
        @attrs = attrs
      end

      def view_template(&)
        user_class = @attrs.delete(:class)
        label(for: @for_, **@attrs, class: merge_class(tokens, user_class), &)
      end
    end
  end
end
