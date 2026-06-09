# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class RadioGroup < Wabi::Base
      # +aria_label:+ provides an accessible name for the radiogroup landmark.
      # Callers should supply a concise string describing the group, e.g.
      # <tt>aria_label: "Subscription plan"</tt>. Alternatively pass
      # <tt>aria_labelledby: "some-heading-id"</tt> via **attrs to reference
      # an existing heading; callers must supply at least one of the two.
      def initialize(name:, value: nil, disabled: false, aria_label: nil, **attrs)
        @name       = name
        @value      = value
        @disabled   = disabled
        @aria_label = aria_label
        @attrs      = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          **@attrs,
          role: "radiogroup",
          aria: { label: @aria_label },
          data: {
            controller: "wabi--radio-group",
            "wabi--radio-group-name-value":     @name,
            "wabi--radio-group-value-value":    @value,
            "wabi--radio-group-disabled-value": @disabled.to_s,
          },
          class: merge_class("grid gap-2", user_class),
          &block
        )
      end
    end
  end
end
