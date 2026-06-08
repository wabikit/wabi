# frozen_string_literal: true

require "wabi"
require_relative "color_picker"
require_relative "color_picker_label"
require_relative "color_picker_control"
require_relative "color_picker_trigger"
require_relative "color_picker_value_swatch"
require_relative "color_picker_value_text"
require_relative "color_picker_content"
require_relative "color_picker_area"
require_relative "color_picker_channel_slider"
require_relative "color_picker_channel_input"
require_relative "color_picker_swatch_group"
require_relative "color_picker_swatch"

RSpec.describe "ColorPicker composition" do
  describe Components::UI::ColorPicker do
    it "renders a div wired to the wabi--color-picker controller" do
      output = described_class.new.call
      expect(output).to include('data-controller="wabi--color-picker"')
    end

    it "serializes value and format" do
      output = described_class.new(value: "#3b82f6", format: "hsla").call
      expect(output).to include('data-wabi--color-picker-value-value="#3b82f6"')
      expect(output).to include('data-wabi--color-picker-format-value="hsla"')
    end

    it "renders a hidden input only when name is given" do
      expect(described_class.new(name: "brand").call).to include('data-wabi--color-picker-target="hiddenInput"')
      expect(described_class.new.call).not_to include('data-wabi--color-picker-target="hiddenInput"')
    end

    it "yields its block" do
      expect(described_class.new.call { "INNER" }).to include("INNER")
    end
  end

  describe Components::UI::ColorPickerControl do
    it "renders the control region and yields" do
      output = described_class.new.call { "X" }
      expect(output).to include('data-wabi--color-picker-target="control"')
      expect(output).to include("X")
    end
    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--color-picker-target="control"')
    end
  end

  describe Components::UI::ColorPickerTrigger do
    it "renders a trigger button and yields" do
      output = described_class.new.call { "T" }
      expect(output).to include('data-wabi--color-picker-target="trigger"')
      expect(output).to include("T")
    end
    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--color-picker-target="trigger"')
    end
  end

  describe Components::UI::ColorPickerValueSwatch do
    it "renders the current-color swatch target" do
      expect(described_class.new.call).to include('data-wabi--color-picker-target="valueSwatch"')
    end
  end

  describe Components::UI::ColorPickerValueText do
    it "renders the value text target" do
      expect(described_class.new.call).to include('data-wabi--color-picker-target="valueText"')
    end
  end

  describe Components::UI::ColorPickerLabel do
    it "renders a label and yields" do
      output = described_class.new.call { "Brand" }
      expect(output).to include('data-wabi--color-picker-target="label"')
      expect(output).to include("Brand")
    end
    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--color-picker-target="label"')
    end
  end

  describe Components::UI::ColorPickerContent do
    it "renders positioner + content and yields the content body" do
      output = described_class.new.call { "BODY" }
      expect(output).to include('data-wabi--color-picker-target="positioner"')
      expect(output).to include('data-wabi--color-picker-target="content"')
      expect(output).to include("BODY")
    end
    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--color-picker-target="content"')
    end
  end

  describe Components::UI::ColorPickerArea do
    it "renders area + background + thumb targets" do
      output = described_class.new.call
      expect(output).to include('data-wabi--color-picker-target="area"')
      expect(output).to include('data-wabi--color-picker-target="areaBackground"')
      expect(output).to include('data-wabi--color-picker-target="areaThumb"')
    end
  end

  describe Components::UI::ColorPickerChannelSlider do
    it "renders slider + track + thumb carrying the channel" do
      output = described_class.new(channel: "hue").call
      expect(output).to include('data-wabi--color-picker-target="channelSlider"')
      expect(output).to include('data-wabi--color-picker-target="channelSliderTrack"')
      expect(output).to include('data-wabi--color-picker-target="channelSliderThumb"')
      expect(output).to include('data-wabi-channel="hue"')
    end
  end

  describe Components::UI::ColorPickerChannelInput do
    it "renders an input carrying its channel (hex default)" do
      output = described_class.new.call
      expect(output).to include('data-wabi--color-picker-target="channelInput"')
      expect(output).to include('data-wabi-channel="hex"')
    end
  end

  describe Components::UI::ColorPickerSwatchGroup do
    it "renders the swatch group and yields" do
      output = described_class.new.call { "S" }
      expect(output).to include('data-wabi--color-picker-target="swatchGroup"')
      expect(output).to include("S")
    end
    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--color-picker-target="swatchGroup"')
    end
  end

  describe Components::UI::ColorPickerSwatch do
    it "renders a swatch trigger carrying its value" do
      output = described_class.new(value: "#ef4444").call
      expect(output).to include('data-wabi--color-picker-target="swatch"')
      expect(output).to include('data-wabi-value="#ef4444"')
    end
  end
end
