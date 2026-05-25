# frozen_string_literal: true

require "wabi"
require_relative "label"

RSpec.describe Components::UI::Label do
  it "renders a label element with content" do
    output = described_class.new.call { "Email" }
    expect(output).to include("<label")
    expect(output).to include(">Email</label>")
  end

  it "applies the for attribute when for_ is passed" do
    output = described_class.new(for_: "email-input").call { "Email" }
    expect(output).to include('for="email-input"')
  end

  it "applies typography tokens" do
    output = described_class.new.call { "Name" }
    expect(output).to include("text-sm")
    expect(output).to include("font-medium")
  end
end
