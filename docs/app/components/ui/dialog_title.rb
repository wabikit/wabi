# frozen_string_literal: true

require "date"

module Components
  module UI
    class DialogTitle < Wabi::Base
      variants { base "text-lg font-semibold leading-none tracking-tight" }

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        h2(
          data: { "wabi--dialog-target": "title" },
          class: merge_class(tokens, user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
