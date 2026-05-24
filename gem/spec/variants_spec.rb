# frozen_string_literal: true

require "wabi/variants"

RSpec.describe Wabi::Variants do
  it "declares a base class string accessible via .tokens" do
    klass = Class.new do
      extend Wabi::Variants
      variants { base "btn rounded" }
    end

    expect(klass.new.tokens).to eq("btn rounded")
  end
end
