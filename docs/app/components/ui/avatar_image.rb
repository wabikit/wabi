# frozen_string_literal: true

module Components
  module UI
    class AvatarImage < Wabi::Base
      variants { base "absolute inset-0 aspect-square h-full w-full object-cover" }

      # Pass alt: with the person/entity name for a meaningful accessible name.
      # The default empty alt marks the image decorative (hidden from AT) — fine
      # when an adjacent AvatarFallback or nearby text already names the avatar.
      def initialize(src:, alt: "", **attrs)
        @src   = src
        @alt   = alt
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        img(src: @src, alt: @alt, **@attrs, class: merge_class(tokens, user_class))
      end
    end
  end
end
