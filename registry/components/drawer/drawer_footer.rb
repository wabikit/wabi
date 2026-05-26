# frozen_string_literal: true

require "date"

module Components
  module UI
    class DrawerFooter < Wabi::Base
      variants { base "mt-auto flex flex-col gap-2" }

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
