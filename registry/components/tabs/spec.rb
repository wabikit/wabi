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

  it "Tabs defaults to the standard variant and marks the group" do
    output = Components::UI::Tabs.new(value: "tab1").call { "" }
    expect(output).to include("group/tabs")
    expect(output).to include('data-variant="standard"')
  end

  it "Tabs emits data-variant=pill when variant: :pill" do
    output = Components::UI::Tabs.new(value: "tab1", variant: :pill).call { "" }
    expect(output).to include('data-variant="pill"')
    expect(output).to include("group/tabs")
  end

  it "TabsList keeps the standard track look and carries gated pill utilities" do
    output = Components::UI::TabsList.new.call { "" }
    expect(output).to include("rounded-md")
    expect(output).to include("bg-muted")
    expect(output).to include("group-data-[variant=pill]/tabs:rounded-full")
    expect(output).to include("group-data-[variant=pill]/tabs:border")
  end

  it "TabsTrigger keeps the standard active look and carries gated pill active utilities" do
    output = Components::UI::TabsTrigger.new(value: "tab1").call { "Tab 1" }
    expect(output).to include("aria-selected:bg-background")
    expect(output).to include("aria-selected:shadow-sm")
    expect(output).to include("group-data-[variant=pill]/tabs:rounded-full")
    expect(output).to include("group-data-[variant=pill]/tabs:aria-selected:bg-primary")
    expect(output).to include("group-data-[variant=pill]/tabs:aria-selected:text-primary-foreground")
  end

  it "TabsList gated pill utilities survive a user class: override" do
    output = Components::UI::TabsList.new(class: "rounded-lg").call { "" }
    expect(output).to include("rounded-lg") # user override wins the plain rounded bucket
    expect(output).to include("group-data-[variant=pill]/tabs:rounded-full")
    expect(output).to include("group-data-[variant=pill]/tabs:border-border")
  end

  it "Tabs emits data-variant=underline when variant: :underline" do
    output = Components::UI::Tabs.new(value: "tab1", variant: :underline).call { "" }
    expect(output).to include('data-variant="underline"')
    expect(output).to include("group/tabs")
  end

  it "TabsList carries gated underline utilities (full-width baseline) without evicting the standard look" do
    output = Components::UI::TabsList.new.call { "" }
    expect(output).to include("group-data-[variant=underline]/tabs:w-full")
    expect(output).to include("group-data-[variant=underline]/tabs:border-b")
    expect(output).to include("group-data-[variant=underline]/tabs:bg-transparent")
    # standard base survives the merge alongside the gated underline tokens
    expect(output).to include("rounded-md")
    expect(output).to include("bg-muted")
  end

  it "TabsTrigger carries gated underline utilities (active bottom border + primary text) without evicting the standard active look" do
    output = Components::UI::TabsTrigger.new(value: "tab1").call { "Tab 1" }
    expect(output).to include("group-data-[variant=underline]/tabs:border-b-[3px]")
    expect(output).to include("group-data-[variant=underline]/tabs:aria-selected:border-b-primary")
    expect(output).to include("group-data-[variant=underline]/tabs:aria-selected:text-primary")
    # standard active state survives the merge
    expect(output).to include("aria-selected:bg-background")
    expect(output).to include("aria-selected:shadow-sm")
  end
end
