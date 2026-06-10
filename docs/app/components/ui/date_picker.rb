# frozen_string_literal: true

require "date"

module Components
  module UI
    class DatePicker < Wabi::Base
      include DatePickerView

      CALENDAR_ICON = %(<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18M8 2v4m8-4v4"/></svg>)

      def initialize(name: nil, selection_mode: :single, default_value: nil,
                     min: nil, max: nil, locale: "en-US", num_of_months: nil,
                     placeholder: nil, aria_label: "Choose date", disabled: false, read_only: false,
                     portal: true, **attrs)
        @name           = name
        @selection_mode = selection_mode
        @default_value  = default_value
        @min            = min
        @max            = max
        @locale         = locale
        @num_of_months  = num_of_months
        @placeholder    = placeholder
        @aria_label     = aria_label
        @disabled       = disabled
        @read_only      = read_only
        @portal         = portal
        @attrs          = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        user_data  = @attrs.delete(:data) || {}
        # user_data.merge(root_data): component/controller keys always win on collision
        # so callers can add data-* attrs but cannot clobber the controller wiring.
        root_data  = date_picker_root_data.merge("wabi--date-picker-portal-value": @portal.to_s)
        div(**@attrs, data: user_data.merge(root_data), class: merge_class("inline-block", user_class)) do
          div(data: { "wabi--date-picker-target": "control" },
              class: "flex items-center rounded-md border border-input bg-background ring-offset-background " \
                     "focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2 " \
                     "data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50") do
            input(type: "text", placeholder: @placeholder, "aria-label": @aria_label,
                  data: { "wabi--date-picker-target": "input" },
                  class: "flex-1 h-10 min-w-0 bg-transparent px-3 text-sm outline-none placeholder:text-muted-foreground")
            # aria-label is the no-JS fallback; the controller localizes it via getTriggerProps.
            button(type: "button", "aria-label": "Open calendar",
                   data: { "wabi--date-picker-target": "trigger" },
                   class: "h-10 w-10 shrink-0 inline-flex items-center justify-center text-muted-foreground hover:text-foreground") do
              raw(safe(CALENDAR_ICON))
            end
          end

          div(data: { "wabi--date-picker-target": "positioner" }, class: "z-50 pointer-events-none") do
            # Popover content: starts closed + inert + hidden as a no-JS safety net
            # (the controller clears `hidden` on connect; `data-state=closed` keeps it
            # visually collapsed via opacity until opened). PopoverContent relies on
            # opacity alone; here we also hide for the no-JS case.
            div(data: { "wabi--date-picker-target": "content" }, "data-state": "closed", inert: true, hidden: true,
                class: "z-50 rounded-md border border-border bg-popover p-3 text-popover-foreground shadow-md outline-none " \
                       "pointer-events-auto transition-opacity duration-200 ease-out motion-reduce:transition-none " \
                       "data-[state=open]:opacity-100 data-[state=closed]:opacity-0 data-[state=closed]:pointer-events-none") do
              render_calendar_view
            end
          end

          render_hidden_inputs
        end
      end
    end
  end
end
