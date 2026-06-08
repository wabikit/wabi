# frozen_string_literal: true

require "date"

module Components
  module UI
    class ColorPickerChannelInput < Wabi::Base
      def initialize(channel: "hex", **attrs)
        @channel = channel
        @attrs   = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        input(
          data: { "wabi--color-picker-target": "channelInput", "wabi-channel": @channel.to_s },
          class: merge_class(
            "mt-3 w-full rounded border border-input bg-background px-2 py-1 text-sm uppercase",
            user_class
          )
        )
      end
    end
  end
end
