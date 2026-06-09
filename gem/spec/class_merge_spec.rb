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

    it "returns nil (not empty string) when the merged result is empty, so the class attr is omitted" do
      expect(described_class.call).to be_nil
      expect(described_class.call(nil)).to be_nil
      expect(described_class.call(nil, "")).to be_nil
    end

    it "still merges non-empty classes normally" do
      expect(described_class.call("a", "b")).to eq("a b")
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

    it "distinguishes border-width from border-color" do
      expect(described_class.call("border-2 border-input")).to eq("border-2 border-input")
    end

    it "distinguishes ring-width, ring-color, and ring-offset-width" do
      # All three are independent CSS properties; the focus ring needs all of
      # them (width + color + offset). Naive dedup would let one wipe the
      # others.
      expect(described_class.call("ring-2 ring-ring ring-offset-2"))
        .to eq("ring-2 ring-ring ring-offset-2")
    end

    it "distinguishes text-size from text-color" do
      expect(described_class.call("text-sm text-foreground"))
        .to eq("text-sm text-foreground")
    end

    it "distinguishes text-alignment from text-size and text-color" do
      # text-left (align), text-sm (size), text-muted-foreground (color) are
      # three independent CSS properties and must all survive dedup.
      expect(described_class.call("text-left text-sm text-muted-foreground"))
        .to eq("text-left text-sm text-muted-foreground")
    end

    it "still dedups within the same text category" do
      expect(described_class.call("text-left text-center")).to eq("text-center")
    end

    it "still dedups within the same category" do
      expect(described_class.call("text-sm text-base")).to eq("text-base")
      expect(described_class.call("ring-2 ring-4")).to eq("ring-4")
      expect(described_class.call("text-foreground text-muted-foreground"))
        .to eq("text-muted-foreground")
    end

    it "handles `ring-offset-{color}` separately from `ring-offset-{width}`" do
      expect(described_class.call("ring-offset-2 ring-offset-input"))
        .to eq("ring-offset-2 ring-offset-input")
    end

    it "preserves negative-axis translates" do
      expect(described_class.call("-translate-x-1/2 -translate-y-1/2"))
        .to eq("-translate-x-1/2 -translate-y-1/2")
    end
  end
end
