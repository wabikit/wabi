# frozen_string_literal: true

module Components
  module UI
    class CardContent < Wabi::Base
      variants do
        base "px-6"

        # `:with_header` (default) mantiene el comportamiento shadcn: sin padding
        # arriba porque CardContent va debajo de un CardHeader.
        # `:standalone` agrega padding vertical simétrico para cards sin header.
        variant :padding, {
          with_header: "pt-0 pb-6",
          standalone:  "py-6"
        }, default: :with_header
      end

      def initialize(padding: nil, **attrs)
        @padding = padding
        @attrs   = attrs
      end

      def view_template(&)
        user_class = @attrs.delete(:class)
        div(**@attrs, class: merge_class(tokens(padding: @padding), user_class), &)
      end
    end
  end
end
