# frozen_string_literal: true

require "wabi"
require_relative "input_otp"

RSpec.describe "InputOtp" do
  it "wires the controller + core data-values" do
    out = Components::UI::InputOtp.new(name: "user[otp]").call
    expect(out).to include('data-controller="wabi--input-otp"')
    expect(out).to include('data-wabi--input-otp-length-value="6"')
    expect(out).to include('data-wabi--input-otp-type-value="numeric"')
    expect(out).to include('data-wabi--input-otp-otp-value="true"')
    expect(out).to include('data-wabi--input-otp-mask-value="false"')
  end

  it "renders `length` slot inputs" do
    out = Components::UI::InputOtp.new(name: "c", length: 4).call
    expect(out.scan('data-wabi--input-otp-target="slot"').size).to eq(4)
    expect(out).to include('data-wabi--input-otp-length-value="4"')
  end

  it "emits one hidden input named after :name" do
    out = Components::UI::InputOtp.new(name: "user[otp]").call
    expect(out).to match(/<input[^>]*type="hidden"[^>]*name="user\[otp\]"[^>]*data-wabi--input-otp-target="hiddenValue"/)
  end

  it "reflects type, mask, default_value, disabled" do
    out = Components::UI::InputOtp.new(name: "c", type: :alphanumeric, mask: true, default_value: "12", disabled: true).call
    expect(out).to include('data-wabi--input-otp-type-value="alphanumeric"')
    expect(out).to include('data-wabi--input-otp-mask-value="true"')
    expect(out).to include('data-wabi--input-otp-default-value-value="12"')
    expect(out).to include('data-wabi--input-otp-disabled-value="true"')
  end

  it "forwards id + merges class on the root" do
    out = Components::UI::InputOtp.new(name: "c", id: "otp1", class: "gap-3").call
    expect(out).to include('id="otp1"')
    expect(out).to include("gap-3")
  end
end
