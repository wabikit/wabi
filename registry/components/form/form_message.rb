# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
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
