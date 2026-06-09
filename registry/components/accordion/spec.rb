# frozen_string_literal: true

require "wabi"
require_relative "accordion"
require_relative "accordion_item"
require_relative "accordion_trigger"
require_relative "accordion_content"

RSpec.describe "Accordion composition" do
  it "renders controller wrapper with default single/collapsible config" do
    output = Components::UI::Accordion.new.call { "" }
    expect(output).to include('data-controller="wabi--accordion"')
    expect(output).to include('data-wabi--accordion-multiple-value="false"')
    expect(output).to include('data-wabi--accordion-collapsible-value="true"')
    expect(output).to include('data-wabi--accordion-value-value="[]"')
  end

  it "supports multiple mode" do
    output = Components::UI::Accordion.new(type: :multiple).call { "" }
    expect(output).to include('data-wabi--accordion-multiple-value="true"')
  end

  it "serializes initial value as JSON array" do
    output = Components::UI::Accordion.new(value: ["item-1", "item-2"]).call { "" }
    expect(output).to include('data-wabi--accordion-value-value="[&quot;item-1&quot;,&quot;item-2&quot;]"')
  end

  it "AccordionItem carries value + item target" do
    output = Components::UI::AccordionItem.new(value: "q1").call { "" }
    expect(output).to include('data-wabi--accordion-target="item"')
    expect(output).to include('data-wabi-value="q1"')
  end

  it "AccordionTrigger renders inside h3 with button + chevron svg" do
    output = Components::UI::AccordionTrigger.new(value: "q1").call { "Question?" }
    expect(output).to include('<h3')
    expect(output).to include('<button')
    expect(output).to include('data-wabi--accordion-target="trigger"')
    expect(output).to include('data-wabi-value="q1"')
    expect(output).to include('Question?')
    expect(output).to include('<svg')
  end

  it "AccordionTrigger defaults to h3 wrapper and accepts custom level" do
    # default heading level is h3
    default_output = Components::UI::AccordionTrigger.new(value: "q1").call { "Q" }
    expect(default_output).to include('<h3')
    expect(default_output).not_to include('<h2')

    # level: 2 switches to h2
    h2_output = Components::UI::AccordionTrigger.new(value: "q1", level: 2).call { "Q" }
    expect(h2_output).to include('<h2')
    expect(h2_output).not_to include('<h3')

    # level: nil opts out of heading semantics (plain div wrapper, no <h tag)
    div_output = Components::UI::AccordionTrigger.new(value: "q1", level: nil).call { "Q" }
    expect(div_output).to include('<div')
    expect(div_output).not_to match(/<h[1-6]/)
    # button and trigger target are still present regardless of heading level
    expect(div_output).to include('data-wabi--accordion-target="trigger"')
  end

  it "AccordionContent emits data-state=closed initial + content target" do
    output = Components::UI::AccordionContent.new(value: "q1").call { "Answer" }
    expect(output).to include('data-state="closed"')
    expect(output).to include('data-wabi--accordion-target="content"')
    expect(output).to include('data-wabi-value="q1"')
    expect(output).to include('Answer')
    # Crucially NOT hidden: the grid-rows trick handles visibility, and
    # `hidden` would block the transition.
    expect(output).not_to match(/data-wabi--accordion-target="content"[^>]*\bhidden\b/)
  end

  it "composes into a full accordion" do
    composed = Class.new(Phlex::HTML) do
      def view_template
        render Components::UI::Accordion.new(type: :single, collapsible: true) do
          render Components::UI::AccordionItem.new(value: "item-1") do
            render Components::UI::AccordionTrigger.new(value: "item-1") { "Is it accessible?" }
            render Components::UI::AccordionContent.new(value: "item-1") { "Yes. WAI-ARIA design pattern." }
          end
          render Components::UI::AccordionItem.new(value: "item-2") do
            render Components::UI::AccordionTrigger.new(value: "item-2") { "Is it styled?" }
            render Components::UI::AccordionContent.new(value: "item-2") { "Yes. Themable via your tokens." }
          end
        end
      end
    end.new.call

    expect(composed).to include('data-controller="wabi--accordion"')
    expect(composed).to include('Is it accessible?')
    expect(composed).to include('Yes. Themable via your tokens.')
  end
end
