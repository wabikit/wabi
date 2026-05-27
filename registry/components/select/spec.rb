# frozen_string_literal: true

require "wabi"
require_relative "select"
require_relative "select_trigger"
require_relative "select_value"
require_relative "select_content"
require_relative "select_item"
require_relative "select_label"

RSpec.describe "Select composition" do
  it "wires the root with controller and items as JSON" do
    output = Components::UI::Select.new(
      items: [{ value: "a", label: "A" }, { value: "b", label: "B" }],
      name: "letters",
    ).call { "" }
    expect(output).to include('data-controller="wabi--select"')
    # Phlex 2.x escapes quotes inside attributes -- the JSON payload is intact,
    # just rendered as HTML entities. JS parses it back via Stimulus Array value.
    expect(output).to include('&quot;value&quot;:&quot;a&quot;')
    expect(output).to include('&quot;label&quot;:&quot;B&quot;')
    expect(output).to include('data-wabi--select-target="hiddenSelect"')
  end

  it "carries portal-value true by default" do
    output = Components::UI::Select.new.call { "" }
    expect(output).to include('data-wabi--select-portal-value="true"')
  end

  it "allows portal: false to keep v0.4 in-tree behavior" do
    output = Components::UI::Select.new(portal: false).call { "" }
    expect(output).to include('data-wabi--select-portal-value="false"')
  end

  it "renders SelectTrigger as a <button> with the trigger target" do
    output = Components::UI::SelectTrigger.new.call { "Pick" }
    expect(output).to include('<button')
    expect(output).to include('data-wabi--select-target="trigger"')
    expect(output).to include("Pick")
  end

  it "renders SelectValue as a span pointing at the valueText target" do
    output = Components::UI::SelectValue.new.call
    expect(output).to include('data-wabi--select-target="valueText"')
    expect(output).to include('<span')
  end

  it "renders SelectContent hidden by default with positioner > content > list" do
    output = Components::UI::SelectContent.new.call { "" }
    expect(output).to include('data-wabi--select-target="positioner"')
    expect(output).to include('data-wabi--select-target="content"')
    expect(output).to include('data-wabi--select-target="list"')
    # v0.1.x: visibility moved off `hidden` onto `data-state` so transitions
    # can run. Initial render has `data-state="closed"` + `inert` on content.
    expect(output).to include('data-wabi--select-target="content" data-state="closed"')
    expect(output).to match(/data-wabi--select-target="content"[^>]*\binert\b/)
  end

  it "renders SelectItem with role=option, item target, and item value" do
    output = Components::UI::SelectItem.new(value: "foo").call { "Foo" }
    expect(output).to include('role="option"')
    expect(output).to include('data-wabi--select-target="item"')
    expect(output).to include('data-wabi-value="foo"')
    expect(output).to include("Foo")
  end

  it "renders SelectLabel as a non-interactive group header" do
    output = Components::UI::SelectLabel.new.call { "Fruits" }
    expect(output).to include("<li")
    expect(output).to include("Fruits")
  end

  it "composes into a full select" do
    composed = Class.new(Phlex::HTML) do
      def view_template
        items = [{ value: "apple", label: "Apple" }, { value: "banana", label: "Banana" }]
        render Components::UI::Select.new(items: items, name: "fruit") do
          render Components::UI::SelectTrigger.new do
            render Components::UI::SelectValue.new
          end
          render Components::UI::SelectContent.new do
            render Components::UI::SelectItem.new(value: "apple")  { "Apple" }
            render Components::UI::SelectItem.new(value: "banana") { "Banana" }
          end
        end
      end
    end.new.call

    expect(composed).to include('data-controller="wabi--select"')
    expect(composed).to include('data-wabi--select-target="trigger"')
    expect(composed).to include("Apple")
    expect(composed).to include("Banana")
  end
end
