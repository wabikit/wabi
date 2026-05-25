# frozen_string_literal: true

require "wabi"
require_relative "badge"

RSpec.describe Components::UI::Badge do
  it "renders with primary appearance by default" do
    output = described_class.new.call { "New" }
    expect(output).to include("bg-primary")
    expect(output).to include(">New</div>")
  end

  it "applies secondary, destructive, outline appearances" do
    %i[secondary destructive outline].each do |appearance|
      output = described_class.new(appearance: appearance).call { "x" }
      expect(output).not_to include("bg-primary text-primary-foreground")
    end
  end
end
