# frozen_string_literal: true

require "wabi"
require "json"
require_relative "rating_group"
require_relative "rating_group_label"
require_relative "rating_group_control"
require_relative "rating_group_item"

RSpec.describe "RatingGroup composition" do
  describe Components::UI::RatingGroup do
    it "renders a <div> wired to the wabi--rating-group controller" do
      output = described_class.new(name: "score", value: 3).call
      expect(output).to include('<div')
      expect(output).to include('data-controller="wabi--rating-group"')
      expect(output).to include('data-wabi--rating-group-name-value="score"')
    end

    it "serializes value, count, allow-half and read-only" do
      output = described_class.new(name: "score", value: 2, count: 10, allow_half: true, read_only: true).call
      expect(output).to include('data-wabi--rating-group-value-value="2"')
      expect(output).to include('data-wabi--rating-group-count-value="10"')
      expect(output).to include('data-wabi--rating-group-allow-half-value="true"')
      expect(output).to include('data-wabi--rating-group-read-only-value="true"')
    end

    it "renders `count` item spans with 1-based indices and a hidden input" do
      output = described_class.new(name: "score", value: 3, count: 5).call
      expect(output.scan('data-wabi--rating-group-target="item"').size).to eq(5)
      expect(output).to include('data-wabi-index="1"')
      expect(output).to include('data-wabi-index="5"')
      expect(output).to include('data-wabi--rating-group-target="hiddenInput"')
    end

    it "yields a custom block in place of the default control" do
      output = described_class.new(name: "score").call { "CUSTOM" }
      expect(output).to include("CUSTOM")
      expect(output).to include('data-wabi--rating-group-target="hiddenInput"')
    end

    it "renders without a name: and omits the name attribute" do
      out = described_class.new.call
      expect(out).not_to include('name="')
    end
  end

  describe Components::UI::RatingGroupLabel do
    it "renders a label targeting the controller" do
      output = described_class.new.call { "Rate us" }
      expect(output).to include('data-wabi--rating-group-target="label"')
      expect(output).to include("Rate us")
    end
  end

  describe Components::UI::RatingGroupControl do
    it "renders `count` item spans by default" do
      output = described_class.new(count: 3).call
      expect(output).to include('data-wabi--rating-group-target="control"')
      expect(output.scan('data-wabi--rating-group-target="item"').size).to eq(3)
    end
  end

  describe Components::UI::RatingGroupItem do
    it "renders an indexed star with layered outline + filled svgs" do
      output = described_class.new(index: 2).call
      expect(output).to include('data-wabi-index="2"')
      expect(output).to include("group-data-[half]:[clip-path:inset(0_50%_0_0)]")
      expect(output.scan("<svg").size).to eq(2)
    end
  end
end
