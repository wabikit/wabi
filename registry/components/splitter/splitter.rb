# frozen_string_literal: true

require "json"
require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class Splitter < Wabi::Base
      # panels: array of hashes, e.g. [{ id: "a", minSize: 20 }, { id: "b" }]
      # default_size: optional array of numbers (sizes per panel, summing to 100)
      def initialize(panels:, orientation: :horizontal, default_size: nil, **attrs)
        @panels       = panels
        @orientation  = orientation
        @default_size = default_size
        @attrs        = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        data = {
          controller: "wabi--splitter",
          "wabi--splitter-panels-value":      @panels.to_json,
          "wabi--splitter-orientation-value": @orientation.to_s,
        }
        data["wabi--splitter-default-size-value"] = @default_size.to_json if @default_size

        # Zag's getRootProps sets display:flex, flex-direction, width/height:100%
        # and overflow:hidden inline, so the root needs no layout classes — the
        # Splitter fills its (sized) parent. user_class is for cosmetics (border,
        # rounded) that Zag does not override.
        div(**@attrs, data: data, class: merge_class(user_class)) do
          yield if block_given?
        end
      end
    end
  end
end
