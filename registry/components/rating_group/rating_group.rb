# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class RatingGroup < Wabi::Base
      def initialize(name: nil, value: 0, count: 5, allow_half: false, read_only: false, disabled: false, **attrs)
        # value: 0 (or any <= 0) means "unrated" — Zag treats it as empty; the JS controller uses -1 as its sentinel.
        @name       = name
        @value      = value
        @count      = count
        @allow_half = allow_half
        @read_only  = read_only
        @disabled   = disabled
        @attrs      = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          **@attrs,
          data: {
            controller: "wabi--rating-group",
            "wabi--rating-group-name-value":       @name,
            "wabi--rating-group-value-value":      @value.to_s,
            "wabi--rating-group-count-value":      @count.to_s,
            "wabi--rating-group-allow-half-value": @allow_half.to_s,
            "wabi--rating-group-read-only-value":  @read_only.to_s,
            "wabi--rating-group-disabled-value":   @disabled.to_s,
          },
          class: merge_class("flex flex-col gap-2", user_class)
        ) do
          if block
            yield
          else
            render RatingGroupControl.new(count: @count)
          end
          input(type: "hidden", name: @name, value: @value.to_s, data: { "wabi--rating-group-target": "hiddenInput" })
        end
      end
    end
  end
end
