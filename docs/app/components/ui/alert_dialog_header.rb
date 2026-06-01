# frozen_string_literal: true

require "date"

module Components
  module UI
    class AlertDialogHeader < Wabi::Base
      variants { base "flex flex-col space-y-1.5 text-center sm:text-left" }

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
