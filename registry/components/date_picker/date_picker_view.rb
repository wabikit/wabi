# frozen_string_literal: true
require "date"

module Components
  module UI
    # Shared markup for Calendar + DatePicker so the calendar view and the
    # hidden form inputs never drift. Both components `include` this; the
    # methods call Phlex DSL methods on the including instance.
    module DatePickerView
      CHEVRON_LEFT  = %(<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m15 18-6-6 6-6"/></svg>)
      CHEVRON_RIGHT = %(<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>)

      private

      def date_picker_root_data
        {
          controller: "wabi--date-picker",
          "wabi--date-picker-name-value":           @name,
          "wabi--date-picker-selection-mode-value": @selection_mode.to_s,
          "wabi--date-picker-locale-value":         @locale,
          "wabi--date-picker-default-value-value":  Array(@default_value).compact.map { |d| iso(d) }.join(","),
          "wabi--date-picker-min-value":            @min ? iso(@min) : "",
          "wabi--date-picker-max-value":            @max ? iso(@max) : "",
          "wabi--date-picker-num-of-months-value":  num_of_months.to_s,
          "wabi--date-picker-disabled-value":       @disabled.to_s,
          "wabi--date-picker-readonly-value":       @readonly.to_s,
        }
      end

      def num_of_months
        @num_of_months || (@selection_mode == :range ? 2 : 1)
      end

      def iso(value)
        value.is_a?(String) ? value : value.strftime("%Y-%m-%d")
      end

      def render_calendar_view
        div(data: { "wabi--date-picker-target": "viewControl" }, class: "flex items-center justify-between px-1 pb-2") do
          button(type: "button", "aria-label": "Previous month",
                 data: { "wabi--date-picker-target": "prev" }, class: nav_button_class) { raw(safe(CHEVRON_LEFT)) }
          # Controller fills the month/year label text at connect.
          button(type: "button", data: { "wabi--date-picker-target": "viewTrigger" },
                 class: "text-sm font-medium px-2 py-1 rounded-md hover:bg-accent")
          button(type: "button", "aria-label": "Next month",
                 data: { "wabi--date-picker-target": "next" }, class: nav_button_class) { raw(safe(CHEVRON_RIGHT)) }
        end
        table(class: "w-full border-collapse") do
          thead do
            tr(data: { "wabi--date-picker-target": "gridHead" })
          end
          tbody(data: { "wabi--date-picker-target": "grid" })
        end
      end

      def render_hidden_inputs
        if @selection_mode == :range
          input(type: "hidden", name: "#{@name}[start]", data: { "wabi--date-picker-target": "hiddenStart" })
          input(type: "hidden", name: "#{@name}[end]",   data: { "wabi--date-picker-target": "hiddenEnd" })
        else
          input(type: "hidden", name: @name, data: { "wabi--date-picker-target": "hiddenStart" })
        end
      end

      def nav_button_class
        "h-7 w-7 inline-flex items-center justify-center rounded-md text-muted-foreground " \
          "transition-colors hover:bg-accent hover:text-accent-foreground"
      end
    end
  end
end
