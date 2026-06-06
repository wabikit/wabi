# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    # Thin wrapper around the radiogroup container for manual composition.
    # When `count:` is given (default rendering), renders that many RatingGroupItem spans.
    # When a block is given instead, yields to it (manual composition).
    class RatingGroupControl < Wabi::Base
      def initialize(count: nil, **attrs)
        @count = count
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          **@attrs,
          role: "radiogroup",
          data: { "wabi--rating-group-target": "control" },
          class: merge_class("flex items-center gap-1", user_class)
        ) do
          if block
            yield
          elsif @count
            @count.times do |i|
              render RatingGroupItem.new(index: i + 1)
            end
          end
        end
      end
    end
  end
end
