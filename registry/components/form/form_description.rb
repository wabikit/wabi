# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class FormDescription < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        p(class: merge_class("text-sm text-muted-foreground", user_class)) do
          yield if block_given?
        end
      end
    end
  end
end
