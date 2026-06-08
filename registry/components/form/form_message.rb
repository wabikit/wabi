# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    # Renders a field-level validation error message.
    #
    # Accessible-name convention (WCAG 1.3.1 / 4.1.3):
    #   Pass `id: "#{field_name}_error"` so the adjacent input can reference it via
    #   `aria-describedby: "#{field_name}_error"`. This allows assistive technology
    #   to announce the error when the input is focused.
    #
    #   Example:
    #     render FormMessage.new(model: @user, field: :email, id: "email_error")
    #     # input: aria_describedby: "email_error", aria_invalid: true
    #
    # aria-invalid convention (WCAG 1.3.1):
    #   When FormMessage renders for a field (indicating invalidity), the corresponding
    #   input MUST carry `aria-invalid: true`. FormMessage itself emits role="alert" to
    #   announce the error via live region, but the input's aria-invalid state must be
    #   set by the caller since FormMessage has no direct reference to the input element.
    class FormMessage < Wabi::Base
      def initialize(model: nil, field: nil, text: nil, **attrs)
        @model = model
        @field = field
        @text  = text
        @attrs = attrs
      end

      def view_template
        msg = @text || (@model && @field && @model.errors[@field].first)
        return unless msg

        user_class = @attrs.delete(:class)
        # role="alert" so screen readers announce the validation error when it
        # appears; callers can override via attrs (e.g. role: "status").
        p(role: "alert", **@attrs, class: merge_class("text-sm font-medium text-destructive", user_class)) { msg }
      end
    end
  end
end
