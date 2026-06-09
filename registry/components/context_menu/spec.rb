# frozen_string_literal: true

require "wabi"
require_relative "context_menu"
require_relative "context_menu_trigger"
require_relative "context_menu_content"
require_relative "context_menu_item"
require_relative "context_menu_label"
require_relative "context_menu_separator"
require_relative "context_menu_shortcut"
require_relative "context_menu_checkbox_item"
require_relative "context_menu_radio_group"
require_relative "context_menu_radio_item"
require_relative "context_menu_sub"
require_relative "context_menu_sub_trigger"
require_relative "context_menu_sub_content"

RSpec.describe "ContextMenu composition" do
  it "wires the root with controller and open value" do
    output = Components::UI::ContextMenu.new.call { "" }
    expect(output).to include('data-controller="wabi--context-menu"')
    expect(output).to include('data-wabi--context-menu-open-value="false"')
  end

  it "carries portal-value true by default" do
    output = Components::UI::ContextMenu.new.call { "" }
    expect(output).to include('data-wabi--context-menu-portal-value="true"')
  end

  it "allows portal: false to keep in-tree behavior" do
    output = Components::UI::ContextMenu.new(portal: false).call { "" }
    expect(output).to include('data-wabi--context-menu-portal-value="false"')
  end

  it "ContextMenuTrigger emits <button> with the trigger target" do
    output = Components::UI::ContextMenuTrigger.new.call { "Right-click me" }
    expect(output).to include('<button')
    expect(output).to include('data-wabi--context-menu-target="trigger"')
  end

  it "ContextMenuContent starts with data-state=closed + inert on content" do
    output = Components::UI::ContextMenuContent.new.call { "" }
    expect(output).to include('data-wabi--context-menu-target="positioner"')
    expect(output).to include('data-wabi--context-menu-target="content" data-state="closed"')
    expect(output).to match(/data-wabi--context-menu-target="content"[^>]*\binert\b/)
    expect(output).not_to match(/data-wabi--context-menu-target="positioner"[^>]*hidden/)
  end

  it "ContextMenuContent includes motion-reduce:transition-none for prefers-reduced-motion support" do
    output = Components::UI::ContextMenuContent.new.call { "" }
    expect(output).to include("motion-reduce:transition-none")
  end

  it "ContextMenuItem emits role=menuitem with value + disabled data attrs" do
    output = Components::UI::ContextMenuItem.new(value: "edit").call { "Edit" }
    expect(output).to include('role="menuitem"')
    expect(output).to include('data-wabi--context-menu-target="item"')
    expect(output).to include('data-wabi-value="edit"')
    expect(output).to include('data-wabi-disabled="false"')
  end

  it "ContextMenuItem merges user-supplied data attrs into the emitted hash" do
    output = Components::UI::ContextMenuItem.new(
      value: "edit",
      data: { action: "click->wabi--foo#bar", "wabi-extra": "yes" }
    ).call { "Edit" }
    # User data + component data both render. Component keys still emit.
    expect(output).to include('data-action="click->wabi--foo#bar"')
    expect(output).to include('data-wabi-extra="yes"')
    expect(output).to include('data-wabi--context-menu-target="item"')
    expect(output).to include('data-wabi-value="edit"')
  end

  it "ContextMenuRadioItem merges user-supplied data attrs into the emitted hash" do
    output = Components::UI::ContextMenuRadioItem.new(
      value: "rose",
      name:  "wabi-theme",
      data: { action: "click->wabi--theme#setTheme", "wabi--theme-theme-param": "rose" }
    ).call { "Rose" }
    expect(output).to include('data-action="click->wabi--theme#setTheme"')
    expect(output).to include('data-wabi--theme-theme-param="rose"')
    expect(output).to include('data-wabi--context-menu-target="optionItem"')
    expect(output).to include('data-wabi-value="rose"')
  end

  it "ContextMenuLabel is non-interactive (no role=menuitem)" do
    output = Components::UI::ContextMenuLabel.new.call { "Actions" }
    expect(output).not_to include("menuitem")
    expect(output).to include("Actions")
  end

  # a11y regression: label must be aria-hidden so AT skips the unlabelled boundary
  it "ContextMenuLabel carries aria-hidden=true" do
    output = Components::UI::ContextMenuLabel.new.call { "File" }
    expect(output).to include('aria-hidden="true"')
  end

  # a11y regression: radio group with an optional accessible name
  it "ContextMenuRadioGroup emits aria-label when label: is provided" do
    output = Components::UI::ContextMenuRadioGroup.new(name: "theme", aria_label: "Theme").call { "" }
    expect(output).to include('aria-label="Theme"')
  end

  it "ContextMenuRadioGroup omits aria-label when label: is absent" do
    output = Components::UI::ContextMenuRadioGroup.new(name: "theme").call { "" }
    expect(output).not_to include("aria-label")
  end

  it "ContextMenuSeparator emits role=separator" do
    output = Components::UI::ContextMenuSeparator.new.call
    expect(output).to include('role="separator"')
  end

  it "ContextMenuShortcut emits a span" do
    output = Components::UI::ContextMenuShortcut.new.call { "⌘K" }
    expect(output).to include("<span")
    expect(output).to include("⌘K")
  end

  it "ContextMenuCheckboxItem renders role=menuitemcheckbox with aria-checked + data-state" do
    output = Components::UI::ContextMenuCheckboxItem.new(value: "wifi", checked: true).call { "Wi-Fi" }
    expect(output).to include('role="menuitemcheckbox"')
    expect(output).to include('aria-checked="true"')
    expect(output).to include('data-state="checked"')
    expect(output).to include('data-wabi--context-menu-target="optionItem"')
    expect(output).to include('data-wabi-type="checkbox"')
    expect(output).to include("Wi-Fi")
  end

  it "ContextMenuCheckboxItem hides the indicator when unchecked" do
    output = Components::UI::ContextMenuCheckboxItem.new(value: "wifi").call { "Wi-Fi" }
    expect(output).to include('data-state="unchecked"')
    expect(output).to match(/data-wabi--context-menu-target="optionItemIndicator"[^>]*hidden/)
  end

  it "ContextMenuRadioGroup wraps with role=group + propagates the name" do
    output = Components::UI::ContextMenuRadioGroup.new(name: "sort", value: "asc").call { "" }
    expect(output).to include('role="group"')
    expect(output).to include('data-wabi--context-menu-target="radioGroup"')
    expect(output).to include('data-wabi-name="sort"')
  end

  it "ContextMenuRadioItem renders role=menuitemradio carrying name + value" do
    output = Components::UI::ContextMenuRadioItem.new(value: "asc", name: "sort", checked: true).call { "Ascending" }
    expect(output).to include('role="menuitemradio"')
    expect(output).to include('aria-checked="true"')
    expect(output).to include('data-wabi-name="sort"')
    expect(output).to include('data-wabi-type="radio"')
    expect(output).to include("Ascending")
  end

  it "ContextMenuSub marks the boundary with the sub target and display:contents" do
    output = Components::UI::ContextMenuSub.new.call { "" }
    expect(output).to include('data-wabi--context-menu-target="sub"')
    expect(output).to include('class="contents"')
  end

  it "ContextMenuSubTrigger emits role=menuitem with aria-haspopup=menu + chevron" do
    output = Components::UI::ContextMenuSubTrigger.new(value: "share").call { "Share" }
    expect(output).to include('role="menuitem"')
    expect(output).to include('aria-haspopup="menu"')
    expect(output).to include('data-wabi--context-menu-target="subTrigger"')
    expect(output).to include('data-wabi-value="share"')
    expect(output).to include('data-wabi-disabled="false"')
    expect(output).to include('Share')
    expect(output).to include('<svg')
  end

  it "ContextMenuSubContent renders positioner + content with initial data-state=closed + inert" do
    output = Components::UI::ContextMenuSubContent.new.call { "" }
    expect(output).to include('data-wabi--context-menu-target="subPositioner"')
    expect(output).to include('data-wabi--context-menu-target="subContent"')
    expect(output).to match(/data-wabi--context-menu-target="subContent"[^>]*data-state="closed"/)
    expect(output).to match(/data-wabi--context-menu-target="subContent"[^>]*\binert\b/)
  end

  it "composes a menu with a nested submenu containing items + checkboxes" do
    composed = Class.new(Phlex::HTML) do
      def view_template
        render Components::UI::ContextMenu.new do
          render Components::UI::ContextMenuTrigger.new { "Open" }
          render Components::UI::ContextMenuContent.new do
            render Components::UI::ContextMenuItem.new(value: "edit") { "Edit" }
            render Components::UI::ContextMenuSub.new do
              render Components::UI::ContextMenuSubTrigger.new(value: "share") { "Share" }
              render Components::UI::ContextMenuSubContent.new do
                render Components::UI::ContextMenuItem.new(value: "email") { "Email" }
                render Components::UI::ContextMenuCheckboxItem.new(value: "notify_team", checked: true) { "Notify team" }
              end
            end
          end
        end
      end
    end.new.call

    expect(composed).to include('data-wabi--context-menu-target="sub"')
    expect(composed).to include('data-wabi--context-menu-target="subTrigger"')
    expect(composed).to include('data-wabi--context-menu-target="subContent"')
    expect(composed).to include('Share')
    expect(composed).to include('Email')
    expect(composed).to include('Notify team')
    # CheckboxItem inside a sub still uses `optionItem` target -- the
    # controller routes by closest sub ancestor at render time.
    expect(composed).to include('data-wabi--context-menu-target="optionItem"')
  end

  describe "two-level submenu nesting" do
    it "renders nested sub-sub structure with two distinct sub boundaries and unique ids" do
      composed = Class.new(Phlex::HTML) do
        def view_template
          render Components::UI::ContextMenu.new do
            render Components::UI::ContextMenuTrigger.new { "Open" }
            render Components::UI::ContextMenuContent.new do
              render Components::UI::ContextMenuSub.new do
                render Components::UI::ContextMenuSubTrigger.new(value: "share") { "Share" }
                render Components::UI::ContextMenuSubContent.new do
                  render Components::UI::ContextMenuSub.new do
                    render Components::UI::ContextMenuSubTrigger.new(value: "export") { "Export" }
                    render Components::UI::ContextMenuSubContent.new do
                      render Components::UI::ContextMenuItem.new(value: "pdf") { "PDF" }
                    end
                  end
                end
              end
            end
          end
        end
      end.new.call

      expect(composed.scan('data-wabi--context-menu-target="sub"').size).to eq(2)
      sub_ids = composed.scan(/data-wabi-sub-id="([^"]+)"/).flatten
      expect(sub_ids.size).to eq(2)
      expect(sub_ids.uniq.size).to eq(2)
    end
  end

  it "composes into a full menu" do
    composed = Class.new(Phlex::HTML) do
      def view_template
        render Components::UI::ContextMenu.new do
          render Components::UI::ContextMenuTrigger.new { "Right-click me" }
          render Components::UI::ContextMenuContent.new do
            render Components::UI::ContextMenuLabel.new { "Actions" }
            render Components::UI::ContextMenuItem.new(value: "edit")    { "Edit" }
            render Components::UI::ContextMenuItem.new(value: "duplicate") { "Duplicate" }
            render Components::UI::ContextMenuSeparator.new
            render Components::UI::ContextMenuItem.new(value: "delete")  { "Delete" }
          end
        end
      end
    end.new.call

    expect(composed).to include('data-controller="wabi--context-menu"')
    expect(composed).to include('data-wabi--context-menu-target="trigger"')
    expect(composed).to include('data-wabi--context-menu-target="content"')
    expect(composed).to include("Edit")
    expect(composed).to include("Delete")
  end
end
