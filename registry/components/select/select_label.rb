# frozen_string_literal: true

require "date"

module Components
  module UI
    class SelectLabel < Wabi::Base
      variants { base "py-1.5 pl-8 pr-2 text-sm font-semibold text-muted-foreground" }

      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        li(class: merge_class(tokens, user_class)) do
          yield if block_given?
        end
      end
    end
  end
end
