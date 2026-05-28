# frozen_string_literal: true

require "wabi"
require "json"
require_relative "slider"
require_relative "slider_label"
require_relative "slider_track"
require_relative "slider_range"
require_relative "slider_thumb"

RSpec.describe "Slider composition" do
  describe Components::UI::Slider do
    it "renders a <div> wired to the wabi--slider controller" do
      output = described_class.new(name: "volume", value: 50).call
      expect(output).to include('<div')
      expect(output).to include('data-controller="wabi--slider"')
      expect(output).to include('data-wabi--slider-name-value="volume"')
    end

    it "normalizes single integer value to a JSON array" do
      output = described_class.new(name: "volume", value: 50).call
      expect(output).to include('data-wabi--slider-value-value="[50]"')
    end

    it "passes range value as-is" do
      output = described_class.new(name: "price", value: [20, 80]).call
      expect(output).to include('data-wabi--slider-value-value="[20,80]"')
    end

    it "carries min, max, step" do
      output = described_class.new(name: "volume", value: 50, min: 0, max: 100, step: 5).call
      expect(output).to include('data-wabi--slider-min-value="0"')
      expect(output).to include('data-wabi--slider-max-value="100"')
      expect(output).to include('data-wabi--slider-step-value="5"')
    end

    it "carries orientation=vertical when requested" do
      output = described_class.new(name: "volume", value: 50, orientation: :vertical).call
      expect(output).to include('data-wabi--slider-orientation-value="vertical"')
    end

    it "carries orientation=horizontal by default" do
      output = described_class.new(name: "volume", value: 50).call
      expect(output).to include('data-wabi--slider-orientation-value="horizontal"')
    end
  end

  describe Components::UI::SliderTrack do
    it "renders a div carrying the track target" do
      output = described_class.new.call
      expect(output).to include('data-wabi--slider-target="track"')
    end
  end

  describe Components::UI::SliderRange do
    it "renders a div carrying the range target" do
      output = described_class.new.call
      expect(output).to include('data-wabi--slider-target="range"')
    end
  end

  describe Components::UI::SliderThumb do
    it "renders a span with role=slider and the thumb target" do
      output = described_class.new(index: 0).call
      expect(output).to include('role="slider"')
      expect(output).to include('data-wabi--slider-target="thumb"')
      expect(output).to include('data-wabi-index="0"')
    end
  end

  describe Components::UI::SliderLabel do
    it "renders a <label> wired to the label target" do
      output = described_class.new.call { "Volume" }
      expect(output).to start_with("<label")
      expect(output).to include('data-wabi--slider-target="label"')
      expect(output).to include("Volume")
    end
  end
end
