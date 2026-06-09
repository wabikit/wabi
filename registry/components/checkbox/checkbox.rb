# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class Checkbox < Wabi::Base
      variants do
        base "peer h-4 w-4 shrink-0 rounded-sm border border-primary " \
             "ring-offset-background disabled:cursor-not-allowed " \
             "disabled:opacity-50 data-[state=checked]:bg-primary data-[state=checked]:text-primary-foreground " \
             "inline-flex items-center justify-center"
      end

      def initialize(id: nil, name: nil, value: "1", checked: false, disabled: false, label: nil, **attrs)
        @id       = id
        @name     = name
        @value    = value
        @checked  = checked
        @disabled = disabled
        @label    = label
        @attrs    = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        label(
          data: {
            controller: "wabi--checkbox",
            "wabi--checkbox-checked-value":  @checked.to_s,
            "wabi--checkbox-disabled-value": @disabled.to_s,
            "wabi--checkbox-input-id-value": @id,
            "wabi--checkbox-name-value": @name,
            "wabi--checkbox-value-value": @value,
          },
          # focus-within:ring-* provides the visible focus ring when the sr-only
          # <input> (the true focus receiver) is keyboard-focused (WCAG 2.4.11).
          # w-fit keeps the clickable label sized to its content (box + text) — without
          # it, as a flex/grid item the <label> stretches full-width and the empty
          # space beside the text becomes a click target that toggles the checkbox.
          class: "inline-flex w-fit items-center rounded-sm focus-within:outline-none focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2"
        ) do
          # Native <input type=checkbox> is visually hidden but receives focus,
          # keyboard events, and is the source of truth for form submission.
          # Zag.js spreads handlers and aria-* onto it at hydration.
          input(
            type: "checkbox",
            id: @id,
            name: @name,
            value: @value,
            checked: @checked,
            disabled: @disabled,
            data: { "wabi--checkbox-target": "hiddenInput" },
            class: "sr-only"
          )
          span(
            "data-state": @checked ? "checked" : "unchecked",
            "aria-hidden": "true",
            data: { "wabi--checkbox-target": "control" },
            class: merge_class(tokens, user_class)
          ) do
            span(
              data: { "wabi--checkbox-target": "indicator" },
              hidden: !@checked
            ) do
              raw(safe('<svg aria-hidden="true" focusable="false" class="h-3 w-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>'))
            end
          end
          # Visible label gives the checkbox its accessible name (Zag points the
          # hidden input's aria-labelledby at this label). Provide via a block or
          # the `label:` kwarg; without either the control is unnamed.
          if block_given?
            yield
          elsif @label
            span(class: "ml-2 text-sm") { @label }
          end
        end
      end
    end
  end
end
