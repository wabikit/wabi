# frozen_string_literal: true

require "date"

module Components
  module UI
    class DialogDescription < Wabi::Base
      variants { base "text-sm text-muted-foreground" }

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        p(
          data: { "wabi--dialog-target": "description" },
          class: merge_class(tokens, user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
