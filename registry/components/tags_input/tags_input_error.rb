# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class TagsInputError < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        p(
          data: { "wabi--tags-input-target": "error" },
          class: merge_class("text-sm font-medium text-destructive", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
