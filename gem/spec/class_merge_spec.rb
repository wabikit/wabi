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
  end
end
