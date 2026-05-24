# frozen_string_literal: true

RSpec.describe Wabi do
  it "has a version number" do
    expect(Wabi::VERSION).to match(/\A\d+\.\d+\.\d+/)
  end

  it "defines a base Error class" do
    expect(Wabi::Error).to be < StandardError
  end

  it "auto-loads Wabi::Base" do
    expect(defined?(Wabi::Base)).to eq("constant")
  end
end
