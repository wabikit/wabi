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

  it "applies destructive appearance with readable body text + red accents (WCAG 1.4.3)" do
    output = Components::UI::Alert.new(appearance: :destructive).call { "x" }
    # Body text stays foreground (AA in light + dark); destructive cue = red border + red icon.
    expect(output).to include("text-foreground")
    expect(output).to include("border-destructive/50")
    expect(output).to include("[&>svg]:text-destructive")
    # The body itself must NOT be the (button-tuned, dark-mode-failing) destructive red:
    # a bare `text-destructive` utility is space/quote-prefixed; the allowed icon form
    # is `[&>svg]:text-destructive` (colon-prefixed), which this does not match.
    expect(output).not_to match(/[ "]text-destructive\b/)
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

  it "includes aria-atomic=true so full message is read on live-region updates" do
    output = Components::UI::Alert.new.call { "x" }
    expect(output).to include('aria-atomic="true"')
  end
end
