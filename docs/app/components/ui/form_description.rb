# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    # Renders helper/hint text for a form field.
    #
    # Accessible-name convention (WCAG 1.3.1):
    #   Pass `id: "#{field_name}_description"` and wire the adjacent input with
    #   `aria-describedby: "#{field_name}_description"` so assistive technology
    #   announces the description when the input is focused.
    #
    #   Example:
    #     render FormDescription.new(id: "email_description") { "We'll never share your email." }
    #     # input: aria_describedby: "email_description"
    class FormDescription < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        p(**@attrs, class: merge_class("text-sm text-muted-foreground", user_class)) do
          yield if block_given?
        end
      end
    end
  end
end
