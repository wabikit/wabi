# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class SplitterResizeTrigger < Wabi::Base
      # id is the "<beforePanelId>:<afterPanelId>" pair Zag expects, e.g. "a:b".
      # aria_label: optional accessible name for the resize handle (e.g. "Resize sidebar").
      # The controller reads data-wabi-label at runtime and forwards it as aria-label,
      # falling back to "Resize panels" when nil.
      def initialize(id:, aria_label: nil, **attrs)
        @id         = id
        @aria_label = aria_label
        @attrs      = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        data = { "wabi--splitter-target": "resizeTrigger", "wabi-id": @id.to_s }
        data[:"wabi-label"] = @aria_label if @aria_label
        div(
          data: data,
          class: merge_class(
            "group relative flex items-center justify-center bg-border transition-colors motion-reduce:transition-none " \
            "hover:bg-primary/40 data-[focus]:bg-primary/40 " \
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-1 " \
            "data-[orientation=horizontal]:w-1.5 data-[orientation=horizontal]:cursor-col-resize " \
            "data-[orientation=vertical]:h-1.5 data-[orientation=vertical]:cursor-row-resize",
            user_class
          )
        )
      end
    end
  end
end
