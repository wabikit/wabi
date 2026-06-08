# frozen_string_literal: true

require "wabi"
require_relative "label"

RSpec.describe Components::UI::Label do
  # NOTE: rendering a Label without for_ and without a wrapped control produces
  # a <label> that is not programmatically associated with any input. That usage
  # violates WCAG 1.3.1. The test below documents the bare render as a known
  # (but discouraged) case — do not promote it as correct usage.
  it "renders a label element with content" do
    output = described_class.new.call { "Email" }
    expect(output).to include("<label")
    expect(output).to include(">Email</label>")
  end

  # VALID ASSOCIATION — for_ links label to a control by id (WCAG 1.3.1)
  it "applies the for attribute when for_ is passed" do
    output = described_class.new(for_: "email-input").call { "Email" }
    expect(output).to include('for="email-input"')
  end

  # VALID ASSOCIATION — omitting for_ when block wraps the control is also
  # acceptable (implicit label); no for attribute is emitted in that case.
  it "omits the for attribute when for_ is nil (caller wraps control as block child)" do
    output = described_class.new.call { "Email" }
    expect(output).not_to include("for=")
  end

  it "applies typography tokens" do
    output = described_class.new.call { "Name" }
    expect(output).to include("text-sm")
    expect(output).to include("font-medium")
  end
end
