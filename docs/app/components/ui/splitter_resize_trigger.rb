# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class SplitterResizeTrigger < Wabi::Base
      # id is the "<beforePanelId>:<afterPanelId>" pair Zag expects, e.g. "a:b".
      def initialize(id:, **attrs)
        @id    = id
        @attrs = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--splitter-target": "resizeTrigger", "wabi-id": @id.to_s },
          class: merge_class(
            "group relative flex items-center justify-center bg-border transition-colors " \
            "hover:bg-primary/40 data-[focus]:bg-primary/40 " \
            "data-[orientation=horizontal]:w-1.5 data-[orientation=horizontal]:cursor-col-resize " \
            "data-[orientation=vertical]:h-1.5 data-[orientation=vertical]:cursor-row-resize",
            user_class
          )
        )
      end
    end
  end
end
