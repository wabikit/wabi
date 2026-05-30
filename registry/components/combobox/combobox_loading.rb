# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class ComboboxLoading < Wabi::Base
      def initialize(**attrs)
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          hidden: true,
          data: { "wabi--combobox-target": "loading" },
          class: merge_class("px-2 py-1.5 text-sm text-muted-foreground", user_class)
        ) do
          yield if block_given?
        end
      end
    end
  end
end
