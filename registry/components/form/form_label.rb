# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class FormLabel < Wabi::Base
      LABEL_CLASS = "text-sm font-medium leading-none " \
                    "peer-disabled:cursor-not-allowed peer-disabled:opacity-70"

      def initialize(for: nil, **attrs)
        @for   = binding.local_variable_get(:for)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        label(
          for: @for,
          class: merge_class(LABEL_CLASS, user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
