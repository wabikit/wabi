# frozen_string_literal: true

require "date"

module Components
  module UI
    class ColorPickerChannelSlider < Wabi::Base
      # channel: "hue" | "alpha"
      def initialize(channel:, **attrs)
        @channel = channel
        @attrs   = attrs
      end

      def view_template
        user_class = @attrs.delete(:class)
        div(
          data: { "wabi--color-picker-target": "channelSlider", "wabi-channel": @channel.to_s },
          class: merge_class("relative mt-3 h-3 w-full rounded-full", user_class)
        ) do
          div(
            data: { "wabi--color-picker-target": "channelSliderTrack", "wabi-channel": @channel.to_s },
            class: "absolute inset-0 rounded-full"
          )
          div(
            data: { "wabi--color-picker-target": "channelSliderThumb", "wabi-channel": @channel.to_s },
            class: "absolute top-1/2 h-4 w-4 -translate-x-1/2 -translate-y-1/2 rounded-full border-2 border-white shadow focus-visible:ring-2 focus-visible:ring-white"
          )
        end
      end
    end
  end
end
