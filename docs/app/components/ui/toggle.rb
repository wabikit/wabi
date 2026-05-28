# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    # Pressable toggle button (Bold / Italic style). Diverges from Switch:
    # Switch is a sliding control with a knob (settings-style); Toggle is a
    # button that visually presses in/out (formatting-toolbar style).
    class Toggle < Wabi::Base
      variants do
        base "inline-flex items-center justify-center rounded-md text-sm font-medium " \
             "transition-colors focus-visible:outline-none focus-visible:ring-2 " \
             "focus-visible:ring-ring focus-visible:ring-offset-2 " \
             "disabled:pointer-events-none disabled:opacity-50 " \
             "data-[state=on]:bg-accent data-[state=on]:text-accent-foreground"

        variant :appearance, {
          default: "bg-transparent hover:bg-muted hover:text-muted-foreground",
          outline: "border border-input bg-transparent hover:bg-accent hover:text-accent-foreground",
        }, default: :default

        variant :size, {
          default: "h-10 px-3",
          sm:      "h-9  px-2.5",
          lg:      "h-11 px-5",
        }, default: :default
      end

      def initialize(id: nil, name: nil, pressed: false, disabled: false, appearance: nil, size: nil, **attrs)
        @id         = id
        @name       = name
        @pressed    = pressed
        @disabled   = disabled
        @appearance = appearance
        @size       = size
        @attrs      = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          **@attrs,
          id: @id,
          type: "button",
          "data-state": @pressed ? "on" : "off",
          data: {
            controller: "wabi--toggle",
            "wabi--toggle-pressed-value":  @pressed.to_s,
            "wabi--toggle-disabled-value": @disabled.to_s,
            "wabi--toggle-name-value":     @name,
          },
          class: merge_class(tokens(appearance: @appearance, size: @size), user_class),
          &block
        )
      end
    end
  end
end
