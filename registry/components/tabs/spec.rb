# frozen_string_literal: true

require "wabi"
require_relative "tabs"
require_relative "tabs_list"
require_relative "tabs_trigger"
require_relative "tabs_content"

RSpec.describe "Tabs composition" do
  it "Tabs renders controller wrapper with initial value" do
    output = Components::UI::Tabs.new(value: "tab1").call { "" }
    expect(output).to include('data-controller="wabi--tabs"')
    expect(output).to include('data-wabi--tabs-value-value="tab1"')
    expect(output).to include('data-wabi--tabs-activation-mode-value="automatic"')
  end

  it "Tabs accepts manual activation_mode" do
    output = Components::UI::Tabs.new(value: "tab1", activation_mode: :manual).call { "" }
    expect(output).to include('data-wabi--tabs-activation-mode-value="manual"')
  end

  it "TabsList has role=tablist with list target" do
    output = Components::UI::TabsList.new.call { "" }
    expect(output).to include('role="tablist"')
    expect(output).to include('data-wabi--tabs-target="list"')
  end

  it "TabsTrigger has role=tab with value and trigger target" do
    output = Components::UI::TabsTrigger.new(value: "tab1").call { "Tab 1" }
    expect(output).to include('role="tab"')
    expect(output).to include('data-wabi--tabs-target="trigger"')
    expect(output).to include('data-wabi-value="tab1"')
    expect(output).to include('data-wabi-disabled="false"')
    expect(output).to include("Tab 1")
  end

  it "TabsTrigger forwards disabled flag" do
    output = Components::UI::TabsTrigger.new(value: "tab1", disabled: true).call { "Tab 1" }
    expect(output).to include('data-wabi-disabled="true"')
  end

  it "TabsContent has role=tabpanel and is hidden by default" do
    output = Components::UI::TabsContent.new(value: "tab1").call { "Content" }
    expect(output).to include('role="tabpanel"')
    expect(output).to include('data-wabi--tabs-target="content"')
    expect(output).to include('data-wabi-value="tab1"')
    expect(output).to include('hidden')
    expect(output).to include("Content")
  end

  it "composes into a full tabs widget" do
    composed = Class.new(Phlex::HTML) do
      def view_template
        render Components::UI::Tabs.new(value: "a") do
          render Components::UI::TabsList.new do
            render Components::UI::TabsTrigger.new(value: "a") { "A" }
            render Components::UI::TabsTrigger.new(value: "b") { "B" }
          end
          render Components::UI::TabsContent.new(value: "a") { "Panel A" }
          render Components::UI::TabsContent.new(value: "b") { "Panel B" }
        end
      end
    end.new.call

    expect(composed).to include('data-controller="wabi--tabs"')
    expect(composed).to include("Panel A")
    expect(composed).to include("Panel B")
  end
end
