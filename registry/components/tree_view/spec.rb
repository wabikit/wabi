# frozen_string_literal: true

require "wabi"
require "json"
require_relative "tree_view"

RSpec.describe Components::UI::TreeView do
  let(:items) do
    [
      { value: "src", label: "src", icon: "folder", children: [
        { value: "app.rb", label: "app.rb", icon: "file" },
        { value: "lib", label: "lib", icon: "folder", children: [
          { value: "util.rb", label: "util.rb", icon: "file" }
        ] }
      ] },
      { value: "README", label: "README.md", icon: "file" }
    ]
  end

  it "renders a div wired to the wabi--tree-view controller" do
    expect(described_class.new(items: items).call).to include('data-controller="wabi--tree-view"')
  end

  it "serializes items as JSON and the selection/checkbox/default values" do
    out = described_class.new(items: items, selection_mode: "multiple", with_checkboxes: true,
                              default_expanded: ["src"], default_selected: ["README"]).call
    expect(out).to include('data-wabi--tree-view-selection-mode-value="multiple"')
    expect(out).to include('data-wabi--tree-view-with-checkboxes-value="true"')
    expect(out).to include("&quot;value&quot;:&quot;src&quot;")
    expect(out).to include('data-wabi--tree-view-default-expanded-value="[&quot;src&quot;]"')
    expect(out).to include('data-wabi--tree-view-default-selected-value="[&quot;README&quot;]"')
  end

  it "renders the label only when given" do
    expect(described_class.new(items: items, label: "Files").call).to include('data-wabi--tree-view-target="label"')
    expect(described_class.new(items: items, label: "Files").call).to include("Files")
    expect(described_class.new(items: items).call).not_to include('data-wabi--tree-view-target="label"')
  end

  it "renders the tree container" do
    expect(described_class.new(items: items).call).to include('data-wabi--tree-view-target="tree"')
  end

  it "renders a branch node with its control/trigger/indicator/text/content targets and data attrs" do
    out = described_class.new(items: items).call
    expect(out).to include('data-wabi--tree-view-target="branch"')
    expect(out).to include('data-wabi--tree-view-target="branchControl"')
    expect(out).to include('data-wabi--tree-view-target="branchTrigger"')
    expect(out).to include('data-wabi--tree-view-target="branchIndicator"')
    expect(out).to include('data-wabi--tree-view-target="branchText"')
    expect(out).to include('data-wabi--tree-view-target="branchContent"')
    expect(out).to include('data-wabi-value="src"')
    expect(out).to include('data-wabi-role="branch"')
    expect(out).to include('data-wabi-index-path="[0]"')
  end

  it "renders a leaf item with its text/indicator targets and data attrs" do
    out = described_class.new(items: items).call
    expect(out).to include('data-wabi--tree-view-target="item"')
    expect(out).to include('data-wabi--tree-view-target="itemText"')
    expect(out).to include('data-wabi--tree-view-target="itemIndicator"')
    expect(out).to include('data-wabi-value="README"')
    expect(out).to include('data-wabi-role="item"')
    expect(out).to include('data-wabi-index-path="[1]"')
  end

  it "renders nested children with deep index paths" do
    out = described_class.new(items: items).call
    expect(out).to include('data-wabi-value="util.rb"')
    expect(out).to include('data-wabi-index-path="[0,1,0]"')
  end

  it "renders node checkboxes only when with_checkboxes is true" do
    expect(described_class.new(items: items, with_checkboxes: true).call).to include('data-wabi--tree-view-target="nodeCheckbox"')
    expect(described_class.new(items: items).call).not_to include('data-wabi--tree-view-target="nodeCheckbox"')
  end

  it "renders folder and file icons from the node icon field" do
    out = described_class.new(items: items).call
    expect(out).to include('data-wabi-icon="folder"')
    expect(out).to include('data-wabi-icon="file"')
  end

  it "treats an empty children array as a branch" do
    out = described_class.new(items: [{ value: "empty", label: "Empty", children: [] }]).call
    expect(out).to include('data-wabi-role="branch"')
    expect(out).to include('data-wabi-value="empty"')
  end

  # a11y regression: branchTrigger is icon-only (chevron SVG, no visible text).
  # Zag's getBranchTriggerProps never injects aria-label, so we add a static
  # default in the Ruby markup to satisfy WCAG 4.1.2 (Name, Role, Value).
  it "renders branchTrigger button with a static aria-label for accessible name" do
    out = described_class.new(items: items).call
    # Find the branchTrigger button tag and confirm aria-label is present
    trigger_tag = out[/<button[^>]*data-wabi--tree-view-target="branchTrigger"[^>]*>/]
    expect(trigger_tag).not_to be_nil
    expect(trigger_tag).to include('aria-label="Toggle branch"')
  end

  # Regression: Zag's getItemProps() returns style { --depth } and the controller
  # spreads it onto the item element, REPLACING its style attribute. So the
  # indentation custom property must NOT live on the Zag-managed row element
  # (item / branchControl) — it must live on an inner [data-wabi-indent] wrapper
  # that the controller never touches, or leaf items lose their indentation.
  it "carries node indentation on an inner wrapper, not on the Zag-managed row" do
    out = described_class.new(items: items).call
    expect(out).to include("data-wabi-indent")

    item_tag = out[/<div[^>]*data-wabi-role="item"[^>]*>/]
    expect(item_tag).not_to include("--wabi-tv-pad")
    expect(item_tag).not_to include("pl-[var(--wabi-tv-pad)]")

    control_tag = out[/<div[^>]*data-wabi--tree-view-target="branchControl"[^>]*>/]
    expect(control_tag).not_to include("--wabi-tv-pad")
  end
end
