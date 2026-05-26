# frozen_string_literal: true

require "date"

module Components
  module UI
    class DialogFooter < Wabi::Base
      variants { base "flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2" }

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
