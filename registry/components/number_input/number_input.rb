# frozen_string_literal: true

require "json"

module Components
  module UI
    class NumberInput < Wabi::Base
      variants do
        base "flex items-center rounded-md border border-input bg-background " \
             "ring-offset-background overflow-hidden " \
             "focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2 " \
             "data-[invalid]:border-destructive data-[invalid]:focus-within:ring-destructive " \
             "data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50"

        variant :size, {
          sm: "h-9",
          md: "h-10",
          lg: "h-11"
        }, default: :md
      end

      def initialize(name: nil, value: nil, min: nil, max: nil, step: 1,
                     precision: nil, format: :decimal, currency: "USD",
                     size: :md, allow_mouse_wheel: false, invalid: false,
                     disabled: false, aria_label: nil, **attrs)
        @name              = name
        @value             = value
        @min               = min
        @max               = max
        @step              = step
        @precision         = precision
        @format            = format
        @currency          = currency
        @size              = size
        @allow_mouse_wheel = allow_mouse_wheel
        @invalid           = invalid
        @disabled          = disabled
        # Optional accessible name forwarded to the Zag machine's aria-label option
        # so screen readers announce a meaningful spinbutton label instead of the
        # generic Zag default ("Enter number").  Pass aria_label: "Quantity" (for example).
        @aria_label        = aria_label
        @attrs             = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        # Anatomy: the root is just the Zag root/wrapper (intrinsic width). The
        # bordered, focus-ring, data-[invalid]/[disabled] styling lives on the
        # inner `control` div via tokens(size:) (base + size) — that's where Zag
        # emits data-invalid/data-disabled through getControlProps.
        div(
          **@attrs,
          data: {
            controller: "wabi--number-input",
            "wabi--number-input-name-value":              @name,
            "wabi--number-input-value-value":             @value.nil? ? "" : @value.to_s,
            "wabi--number-input-min-value":               @min.nil? ? "" : @min.to_s,
            "wabi--number-input-max-value":               @max.nil? ? "" : @max.to_s,
            "wabi--number-input-step-value":              @step.to_s,
            "wabi--number-input-format-options-value":    format_options.to_json,
            "wabi--number-input-allow-mouse-wheel-value": @allow_mouse_wheel.to_s,
            "wabi--number-input-invalid-value":           @invalid.to_s,
            "wabi--number-input-disabled-value":          @disabled.to_s,
            "wabi--number-input-aria-label-value":        @aria_label.nil? ? "" : @aria_label.to_s,
          },
          class: merge_class("inline-flex w-fit", user_class)
        ) do
          div(data: { "wabi--number-input-target": "control" }, class: tokens(size: @size)) do
            button(type: "button",
                   data: { "wabi--number-input-target": "decrement" },
                   class: trigger_class) { "−" }

            input(type: "text",
                  inputmode: "decimal",
                  name: @name,
                  data: { "wabi--number-input-target": "input" },
                  class: input_class)

            button(type: "button",
                   data: { "wabi--number-input-target": "increment" },
                   class: trigger_class) { "+" }
          end
        end
      end

      private

      def format_options
        opts =
          case @format
          when :currency then { style: "currency", currency: @currency }
          when :percent  then { style: "percent" }
          else                { style: "decimal" }
          end
        if @precision
          opts[:minimumFractionDigits] = @precision
          opts[:maximumFractionDigits] = @precision
        end
        opts
      end

      def trigger_class
        width = { sm: "w-8", md: "w-10", lg: "w-11" }.fetch(@size, "w-10")
        "#{width} h-full shrink-0 inline-flex items-center justify-center select-none " \
          "text-lg leading-none text-muted-foreground transition-colors motion-reduce:transition-none " \
          "hover:bg-accent hover:text-accent-foreground active:bg-accent/80 " \
          "disabled:pointer-events-none disabled:opacity-50"
      end

      def input_class
        text = @size == :lg ? "text-base" : "text-sm"
        "flex-1 w-full min-w-0 border-x border-input bg-transparent text-center px-2 #{text} " \
          "placeholder:text-muted-foreground focus-visible:outline-none disabled:cursor-not-allowed " \
          "[appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none " \
          "[&::-webkit-inner-spin-button]:appearance-none"
      end
    end
  end
end
