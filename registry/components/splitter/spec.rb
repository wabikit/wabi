# frozen_string_literal: true

require "wabi"
require "json"
require_relative "splitter"
require_relative "splitter_panel"
require_relative "splitter_resize_trigger"

RSpec.describe "Splitter composition" do
  describe Components::UI::Splitter do
    it "renders a <div> wired to the wabi--splitter controller" do
      output = described_class.new(panels: [{ id: "a" }, { id: "b" }]).call
      expect(output).to include('data-controller="wabi--splitter"')
    end

    it "serializes panels and orientation" do
      output = described_class.new(panels: [{ id: "a", minSize: 20 }, { id: "b" }], orientation: :vertical).call
      expect(output).to include('data-wabi--splitter-orientation-value="vertical"')
      expect(output).to include("&quot;id&quot;:&quot;a&quot;")
    end

    it "yields its block" do
      output = described_class.new(panels: [{ id: "a" }, { id: "b" }]).call { "INNER" }
      expect(output).to include("INNER")
    end

    it "serializes default_size when provided" do
      output = described_class.new(panels: [{ id: "a" }, { id: "b" }], default_size: [30, 70]).call
      expect(output).to include('data-wabi--splitter-default-size-value="[30,70]"')
    end
  end

  describe Components::UI::SplitterPanel do
    it "renders a panel carrying its id" do
      output = described_class.new(id: "a").call { "Left" }
      expect(output).to include('data-wabi--splitter-target="panel"')
      expect(output).to include('data-wabi-id="a"')
      expect(output).to include("Left")
    end

    it "renders without a block" do
      expect(described_class.new(id: "a").call).to include('data-wabi-id="a"')
    end
  end

  describe Components::UI::SplitterResizeTrigger do
    it "renders a resize gutter carrying the before:after id" do
      output = described_class.new(id: "a:b").call
      expect(output).to include('data-wabi--splitter-target="resizeTrigger"')
      expect(output).to include('data-wabi-id="a:b"')
    end
  end
end
