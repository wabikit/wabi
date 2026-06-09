# frozen_string_literal: true

require "json"
require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class TagsInput < Wabi::Base
      def initialize(name: nil, value: [], max: nil, editable: true, disabled: false, placeholder: nil, **attrs)
        @name        = name
        @value       = Array(value)
        @max         = max
        @editable    = editable
        @disabled    = disabled
        @placeholder = placeholder
        @attrs       = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          **@attrs,
          data: {
            controller: "wabi--tags-input",
            "wabi--tags-input-name-value":        @name,
            "wabi--tags-input-value-value":       @value.to_json,
            "wabi--tags-input-max-value":         @max.to_s,
            "wabi--tags-input-editable-value":    @editable.to_s,
            "wabi--tags-input-disabled-value":    @disabled.to_s,
            "wabi--tags-input-placeholder-value": @placeholder.to_s,
          },
          class: merge_class("flex flex-col gap-2", user_class)
        ) do
          if block
            yield
          else
            render TagsInputControl.new do
              render TagsInputInput.new(placeholder: @placeholder)
            end
          end
        end
      end
    end
  end
end
