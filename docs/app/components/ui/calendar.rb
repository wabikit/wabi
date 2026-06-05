# frozen_string_literal: true
require "date"

module Components
  module UI
    class Calendar < Wabi::Base
      include DatePickerView

      def initialize(name:, selection_mode: :single, default_value: nil,
                     min: nil, max: nil, locale: "en-US", num_of_months: nil,
                     disabled: false, readonly: false, **attrs)
        @name           = name
        @selection_mode = selection_mode
        @default_value  = default_value
        @min            = min
        @max            = max
        @locale         = locale
        @num_of_months  = num_of_months
        @disabled       = disabled
        @readonly       = readonly
        @attrs          = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        user_data  = @attrs.delete(:data) || {}
        div(**@attrs,
            data: user_data.merge(date_picker_root_data),
            class: merge_class("inline-block rounded-md border border-border bg-background p-3", user_class)) do
          render_calendar_view
          render_hidden_inputs
        end
      end
    end
  end
end
