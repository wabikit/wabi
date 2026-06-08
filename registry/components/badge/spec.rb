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

  it "uses focus-visible ring utilities instead of focus: (WCAG 2.4.11)" do
    output = described_class.new.call { "New" }
    expect(output).to include("focus-visible:outline-none")
    expect(output).to include("focus-visible:ring-2")
    expect(output).to include("focus-visible:ring-ring")
    expect(output).to include("focus-visible:ring-offset-2")
    expect(output).not_to include("focus:ring-")
    expect(output).not_to include("focus:outline-none")
  end

  it "forwards role: and other attrs to the root element" do
    output = described_class.new(role: "status").call { "3" }
    expect(output).to include('role="status"')
  end
end
