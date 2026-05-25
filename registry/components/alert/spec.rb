# frozen_string_literal: true

require "wabi"
require_relative "alert"
require_relative "alert_title"
require_relative "alert_description"

RSpec.describe "Alert composition" do
  it "renders Alert with role=alert" do
    output = Components::UI::Alert.new.call { "x" }
    expect(output).to include('role="alert"')
    expect(output).to include("rounded-lg")
  end

  it "applies destructive appearance" do
    output = Components::UI::Alert.new(appearance: :destructive).call { "x" }
    expect(output).to include("text-destructive")
  end

  it "renders AlertTitle as h5" do
    output = Components::UI::AlertTitle.new.call { "Heads up" }
    expect(output).to include("<h5")
    expect(output).to include("font-medium")
  end

  it "renders AlertDescription as div" do
    output = Components::UI::AlertDescription.new.call { "Details" }
    expect(output).to include("<div")
    expect(output).to include("text-sm")
  end
end
