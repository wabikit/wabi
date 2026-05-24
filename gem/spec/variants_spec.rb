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

  it "resolves named variant options" do
    klass = Class.new do
      extend Wabi::Variants
      variants do
        base "btn"
        variant :size, { sm: "h-8", md: "h-10", lg: "h-12" }, default: :md
      end
    end

    expect(klass.new.tokens(size: :sm)).to eq("btn h-8")
    expect(klass.new.tokens(size: :lg)).to eq("btn h-12")
  end

  it "applies default variant when option not passed" do
    klass = Class.new do
      extend Wabi::Variants
      variants do
        base "btn"
        variant :size, { sm: "h-8", md: "h-10" }, default: :md
      end
    end

    expect(klass.new.tokens).to eq("btn h-10")
  end

  it "ignores unknown variant values silently" do
    klass = Class.new do
      extend Wabi::Variants
      variants do
        base "btn"
        variant :size, { sm: "h-8" }, default: :sm
      end
    end

    expect(klass.new.tokens(size: :xxl)).to eq("btn")
  end

  it "combines multiple variants" do
    klass = Class.new do
      extend Wabi::Variants
      variants do
        base "btn"
        variant :appearance, { primary: "bg-blue", secondary: "bg-gray" }, default: :primary
        variant :size, { sm: "h-8", md: "h-10" }, default: :md
      end
    end

    expect(klass.new.tokens(appearance: :secondary, size: :sm)).to eq("btn bg-gray h-8")
  end

  it "child class can override parent variants when extending Wabi::Base" do
    parent = Class.new(Wabi::Base) do
      variants do
        base "btn"
        variant :size, { sm: "h-8", md: "h-10" }, default: :md
      end
    end

    child = Class.new(parent) do
      variants do
        base "btn-large"
        variant :size, { xl: "h-16" }, default: :xl
      end
    end

    expect(parent.new.tokens).to eq("btn h-10")
    expect(child.new.tokens).to eq("btn-large h-16")
  end
end
