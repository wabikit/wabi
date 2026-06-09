# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class Switch < Wabi::Base
      variants do
        # The control span is aria-hidden and never itself focused — the sr-only
        # <input> is. Zag spreads data-focus-visible onto this span when the input
        # is keyboard-focused, so the focus ring must use data-[focus-visible]:
        # variants (focus-visible: pseudo-class would never fire here).
        base "inline-flex h-6 w-11 shrink-0 cursor-pointer items-center rounded-full " \
             "border-2 border-transparent transition-colors motion-reduce:transition-none outline-none " \
             "data-[focus-visible]:ring-2 data-[focus-visible]:ring-ring data-[focus-visible]:ring-offset-2 " \
             "data-[focus-visible]:ring-offset-background disabled:cursor-not-allowed disabled:opacity-50 " \
             "data-[state=checked]:bg-primary data-[state=unchecked]:bg-input"
      end

      THUMB_CLASS = "pointer-events-none block h-5 w-5 rounded-full bg-background shadow-lg " \
                    "ring-0 transition-transform motion-reduce:transition-none data-[state=checked]:translate-x-5 " \
                    "data-[state=unchecked]:translate-x-0"

      LABEL_CLASS = "text-sm font-medium leading-none"

      # aria_label: gives the switch an accessible name when no visible label
      # (block) is rendered. It is forwarded to the hidden <input>; the
      # controller strips Zag's dangling aria-labelledby in that case so the
      # aria-label is the effective accessible name. Pass a block to render a
      # visible label instead (which Zag wires via aria-labelledby).
      def initialize(id: nil, name: nil, checked: false, disabled: false, aria_label: nil, **attrs)
        @id         = id
        @name       = name
        @checked    = checked
        @disabled   = disabled
        @aria_label = aria_label
        @attrs      = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        label(
          data: {
            controller: "wabi--switch",
            "wabi--switch-checked-value":  @checked.to_s,
            "wabi--switch-disabled-value": @disabled.to_s,
            "wabi--switch-input-id-value": @id,
            "wabi--switch-name-value": @name,
          },
          # w-fit keeps the clickable label sized to its content — without it, as a
          # flex/grid item the <label> stretches full-width and the empty space beside
          # the text becomes a click target that toggles the switch.
          class: "inline-flex w-fit items-center gap-2"
        ) do
          input(
            type: "checkbox",
            id: @id,
            name: @name,
            checked: @checked,
            disabled: @disabled,
            "aria-label": @aria_label,
            data: { "wabi--switch-target": "hiddenInput" },
            class: "sr-only"
          )
          span(
            "data-state": @checked ? "checked" : "unchecked",
            "aria-hidden": "true",
            data: { "wabi--switch-target": "control" },
            class: merge_class(tokens, user_class)
          ) do
            span(
              "data-state": @checked ? "checked" : "unchecked",
              data: { "wabi--switch-target": "thumb" },
              class: THUMB_CLASS
            )
          end
          if block
            span(data: { "wabi--switch-target": "label" }, class: LABEL_CLASS, &block)
          end
        end
      end
    end
  end
end
