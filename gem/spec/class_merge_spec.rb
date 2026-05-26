# frozen_string_literal: true

require "wabi/class_merge"

RSpec.describe Wabi::ClassMerge do
  describe ".call" do
    it "concatenates simple class strings" do
      expect(described_class.call("btn", "shadow")).to eq("btn shadow")
    end

    it "deduplicates identical tokens" do
      expect(described_class.call("btn shadow", "shadow")).to eq("btn shadow")
    end

    it "later token wins for the same Tailwind group prefix" do
      expect(described_class.call("h-8", "h-10")).to eq("h-10")
      expect(described_class.call("bg-red-500", "bg-blue-500")).to eq("bg-blue-500")
    end

    it "ignores nil and empty inputs" do
      expect(described_class.call(nil, "btn", "")).to eq("btn")
    end

    it "preserves non-conflicting utilities" do
      expect(described_class.call("flex items-center", "justify-between p-4"))
        .to eq("flex items-center justify-between p-4")
    end

    it "treats variant-scoped utilities as a separate group from their plain counterparts" do
      # `hover:bg-red-500` must not collide with `bg-blue-500` (different scopes).
      expect(described_class.call("bg-blue-500 hover:bg-red-500"))
        .to eq("bg-blue-500 hover:bg-red-500")
    end

    it "keeps multiple data-attribute variants of the same utility prefix" do
      # `data-[state=checked]:bg-primary` and `data-[state=unchecked]:bg-input`
      # target distinct selectors; both must survive dedup.
      classes = "data-[state=checked]:bg-primary data-[state=unchecked]:bg-input"
      expect(described_class.call(classes)).to eq(classes)
    end

    it "deduplicates within a single variant scope (last token wins)" do
      expect(described_class.call("focus-visible:ring-2", "focus-visible:ring-4"))
        .to eq("focus-visible:ring-4")
    end

    it "keeps `data-[state=checked]:bg-X` alongside `data-[state=checked]:text-Y`" do
      # Different utility prefixes (`bg` vs `text`) within the same variant scope.
      classes = "data-[state=checked]:bg-primary data-[state=checked]:text-primary-foreground"
      expect(described_class.call(classes)).to eq(classes)
    end

    it "treats atom utilities like `flex` as separate from their compound siblings" do
      # `flex` = display:flex; `flex-col` = flex-direction:column. Different
      # CSS properties -- they must coexist on the same element.
      expect(described_class.call("flex flex-col")).to eq("flex flex-col")
      expect(described_class.call("border border-input")).to eq("border border-input")
    end

    it "keeps directional axes distinct for translate/scale/border" do
      # x-axis vs y-axis translate are independent transforms; both must stay.
      expect(described_class.call("-translate-x-1/2 -translate-y-1/2"))
        .to eq("-translate-x-1/2 -translate-y-1/2")
      expect(described_class.call("border-l border-r")).to eq("border-l border-r")
    end

    it "still dedups compound siblings within the same axis family" do
      # `-translate-x-1/2` and `-translate-x-full` are both x-axis translates;
      # last wins.
      expect(described_class.call("-translate-x-1/2 -translate-x-full"))
        .to eq("-translate-x-full")
    end
  end
end
