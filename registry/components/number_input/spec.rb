# frozen_string_literal: true

require "wabi"
require_relative "number_input"

RSpec.describe Components::UI::NumberInput do
  def render_html(**opts) = described_class.new(**opts).call

  it "renders a root div wired to the number-input controller" do
    expect(render_html(name: "qty")).to include('data-controller="wabi--number-input"')
  end

  it "emits the core data-values" do
    html = render_html(name: "qty", value: 5, min: 0, max: 10, step: 2)
    expect(html).to include('data-wabi--number-input-name-value="qty"')
    expect(html).to include('data-wabi--number-input-value-value="5"')
    expect(html).to include('data-wabi--number-input-min-value="0"')
    expect(html).to include('data-wabi--number-input-max-value="10"')
    expect(html).to include('data-wabi--number-input-step-value="2"')
  end

  it "casts booleans to string data-values" do
    html = render_html(name: "qty", disabled: true, invalid: true, allow_mouse_wheel: true)
    expect(html).to include('data-wabi--number-input-disabled-value="true"')
    expect(html).to include('data-wabi--number-input-invalid-value="true"')
    expect(html).to include('data-wabi--number-input-allow-mouse-wheel-value="true"')
  end

  it "leaves value/min/max empty when omitted" do
    html = render_html(name: "qty")
    expect(html).to include('data-wabi--number-input-value-value=""')
    expect(html).to include('data-wabi--number-input-min-value=""')
    expect(html).to include('data-wabi--number-input-max-value=""')
  end

  it "renders decrement and increment trigger buttons with − and +" do
    html = render_html(name: "qty")
    expect(html).to include('data-wabi--number-input-target="decrement"')
    expect(html).to include('data-wabi--number-input-target="increment"')
    expect(html).to include("−") # U+2212 MINUS SIGN
    expect(html).to include("+")
  end

  it "renders a real input carrying the name for native form submit" do
    html = render_html(name: "qty")
    expect(html).to include('data-wabi--number-input-target="input"')
    expect(html).to include('name="qty"')
  end

  it "renders the input as type=text with inputmode=decimal (no native spinners, numeric keyboard)" do
    html = render_html(name: "qty")
    expect(html).to include('type="text"')
    expect(html).to include('inputmode="decimal"')
  end

  it "maps format: :currency to Intl currency options" do
    html = render_html(name: "price", format: :currency, currency: "EUR")
    expect(html).to include("currency")
    expect(html).to include("EUR")
  end

  it "maps format: :percent to percent style" do
    expect(render_html(name: "rate", format: :percent)).to include("percent")
  end

  it "encodes precision as fraction digits" do
    html = render_html(name: "price", format: :currency, precision: 2)
    expect(html).to include("minimumFractionDigits")
    expect(html).to include("maximumFractionDigits")
  end

  it "applies the size height to the control" do
    expect(render_html(name: "q", size: :sm)).to include("h-9")
    expect(render_html(name: "q", size: :md)).to include("h-10")
    expect(render_html(name: "q", size: :lg)).to include("h-11")
  end

  it "forwards user class to the root and arbitrary attrs" do
    html = render_html(name: "q", class: "w-32", id: "myinput")
    expect(html).to include("w-32")
    expect(html).to include('id="myinput"')
  end

  # a11y: label param passes an accessible name to the Zag machine via data-value
  it "emits the aria-label data-value when label: is supplied" do
    html = render_html(name: "qty", label: "Quantity")
    expect(html).to include('data-wabi--number-input-aria-label-value="Quantity"')
  end

  it "emits an empty aria-label data-value when label: is omitted" do
    html = render_html(name: "qty")
    expect(html).to include('data-wabi--number-input-aria-label-value=""')
  end
end
