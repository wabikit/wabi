# frozen_string_literal: true

RSpec.describe Wabi do
  it "has a version number" do
    expect(Wabi::VERSION).to match(/\A\d+\.\d+\.\d+/)
  end

  it "defines a base Error class" do
    expect(Wabi::Error).to be < StandardError
  end
end
