# frozen_string_literal: true

require "wabi"
require_relative "textarea"

RSpec.describe Components::UI::Textarea do
  it "renders a textarea element" do
    output = described_class.new.call
    expect(output).to include("<textarea")
    expect(output).to include("min-h-")
  end

  it "renders content from block" do
    output = described_class.new.call { "default text" }
    expect(output).to include(">default text</textarea>")
  end

  it "forwards rows, cols, name" do
    output = described_class.new(rows: 4, cols: 40, name: "bio").call
    expect(output).to include('rows="4"')
    expect(output).to include('cols="40"')
    expect(output).to include('name="bio"')
  end
end
