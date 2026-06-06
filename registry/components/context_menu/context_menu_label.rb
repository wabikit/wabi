# frozen_string_literal: true

require "date"

module Components
  module UI
    class ContextMenuLabel < Wabi::Base
      variants { base "px-2 py-1.5 text-sm font-semibold" }

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(class: merge_class(tokens, user_class)) do
          yield if block_given?
        end
      end
    end
  end
end
