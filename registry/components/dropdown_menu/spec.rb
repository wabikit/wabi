# frozen_string_literal: true

require "wabi"
require_relative "dropdown_menu"
require_relative "dropdown_menu_trigger"
require_relative "dropdown_menu_content"
require_relative "dropdown_menu_item"
require_relative "dropdown_menu_label"
require_relative "dropdown_menu_separator"
require_relative "dropdown_menu_shortcut"
require_relative "dropdown_menu_checkbox_item"
require_relative "dropdown_menu_radio_group"
require_relative "dropdown_menu_radio_item"
require_relative "dropdown_menu_sub"
require_relative "dropdown_menu_sub_trigger"
require_relative "dropdown_menu_sub_content"

RSpec.describe "DropdownMenu composition" do
  it "wires the root with controller and open value" do
    output = Components::UI::DropdownMenu.new.call { "" }
    expect(output).to include('data-controller="wabi--dropdown-menu"')
    expect(output).to include('data-wabi--dropdown-menu-open-value="false"')
  end

  it "DropdownMenuTrigger emits <button> with the trigger target" do
    output = Components::UI::DropdownMenuTrigger.new.call { "Menu" }
    expect(output).to include('<button')
    expect(output).to include('data-wabi--dropdown-menu-target="trigger"')
  end

  it "DropdownMenuContent starts with data-state=closed + inert on content" do
    output = Components::UI::DropdownMenuContent.new.call { "" }
    expect(output).to include('data-wabi--dropdown-menu-target="positioner"')
    expect(output).to include('data-wabi--dropdown-menu-target="content" data-state="closed"')
    expect(output).to match(/data-wabi--dropdown-menu-target="content"[^>]*\binert\b/)
    expect(output).not_to match(/data-wabi--dropdown-menu-target="positioner"[^>]*hidden/)
  end

  it "DropdownMenuItem emits role=menuitem with value + disabled data attrs" do
    output = Components::UI::DropdownMenuItem.new(value: "edit").call { "Edit" }
    expect(output).to include('role="menuitem"')
    expect(output).to include('data-wabi--dropdown-menu-target="item"')
    expect(output).to include('data-wabi-value="edit"')
    expect(output).to include('data-wabi-disabled="false"')
  end

  it "DropdownMenuItem merges user-supplied data attrs into the emitted hash" do
    output = Components::UI::DropdownMenuItem.new(
      value: "edit",
      data: { action: "click->wabi--foo#bar", "wabi-extra": "yes" }
    ).call { "Edit" }
    # User data + component data both render. Component keys still emit.
    expect(output).to include('data-action="click->wabi--foo#bar"')
    expect(output).to include('data-wabi-extra="yes"')
    expect(output).to include('data-wabi--dropdown-menu-target="item"')
    expect(output).to include('data-wabi-value="edit"')
  end

  it "DropdownMenuRadioItem merges user-supplied data attrs into the emitted hash" do
    output = Components::UI::DropdownMenuRadioItem.new(
      value: "rose",
      name:  "wabi-theme",
      data: { action: "click->wabi--theme#setTheme", "wabi--theme-theme-param": "rose" }
    ).call { "Rose" }
    expect(output).to include('data-action="click->wabi--theme#setTheme"')
    expect(output).to include('data-wabi--theme-theme-param="rose"')
    expect(output).to include('data-wabi--dropdown-menu-target="optionItem"')
    expect(output).to include('data-wabi-value="rose"')
  end

  it "DropdownMenuLabel is non-interactive (no role=menuitem)" do
    output = Components::UI::DropdownMenuLabel.new.call { "Actions" }
    expect(output).not_to include("menuitem")
    expect(output).to include("Actions")
  end

  it "DropdownMenuSeparator emits role=separator" do
    output = Components::UI::DropdownMenuSeparator.new.call
    expect(output).to include('role="separator"')
  end

  it "DropdownMenuShortcut emits a span" do
    output = Components::UI::DropdownMenuShortcut.new.call { "⌘K" }
    expect(output).to include("<span")
    expect(output).to include("⌘K")
  end

  it "DropdownMenuCheckboxItem renders role=menuitemcheckbox with aria-checked + data-state" do
    output = Components::UI::DropdownMenuCheckboxItem.new(value: "wifi", checked: true).call { "Wi-Fi" }
    expect(output).to include('role="menuitemcheckbox"')
    expect(output).to include('aria-checked="true"')
    expect(output).to include('data-state="checked"')
    expect(output).to include('data-wabi--dropdown-menu-target="optionItem"')
    expect(output).to include('data-wabi-type="checkbox"')
    expect(output).to include("Wi-Fi")
  end

  it "DropdownMenuCheckboxItem hides the indicator when unchecked" do
    output = Components::UI::DropdownMenuCheckboxItem.new(value: "wifi").call { "Wi-Fi" }
    expect(output).to include('data-state="unchecked"')
    expect(output).to match(/data-wabi--dropdown-menu-target="optionItemIndicator"[^>]*hidden/)
  end

  it "DropdownMenuRadioGroup wraps with role=group + propagates the name" do
    output = Components::UI::DropdownMenuRadioGroup.new(name: "sort", value: "asc").call { "" }
    expect(output).to include('role="group"')
    expect(output).to include('data-wabi--dropdown-menu-target="radioGroup"')
    expect(output).to include('data-wabi-name="sort"')
  end

  it "DropdownMenuRadioItem renders role=menuitemradio carrying name + value" do
    output = Components::UI::DropdownMenuRadioItem.new(value: "asc", name: "sort", checked: true).call { "Ascending" }
    expect(output).to include('role="menuitemradio"')
    expect(output).to include('aria-checked="true"')
    expect(output).to include('data-wabi-name="sort"')
    expect(output).to include('data-wabi-type="radio"')
    expect(output).to include("Ascending")
  end

  it "DropdownMenuSub marks the boundary with the sub target and display:contents" do
    output = Components::UI::DropdownMenuSub.new.call { "" }
    expect(output).to include('data-wabi--dropdown-menu-target="sub"')
    expect(output).to include('class="contents"')
  end

  it "DropdownMenuSubTrigger emits role=menuitem with aria-haspopup=menu + chevron" do
    output = Components::UI::DropdownMenuSubTrigger.new(value: "share").call { "Share" }
    expect(output).to include('role="menuitem"')
    expect(output).to include('aria-haspopup="menu"')
    expect(output).to include('data-wabi--dropdown-menu-target="subTrigger"')
    expect(output).to include('data-wabi-value="share"')
    expect(output).to include('data-wabi-disabled="false"')
    expect(output).to include('Share')
    expect(output).to include('<svg')
  end

  it "DropdownMenuSubContent renders positioner + content with initial data-state=closed + inert" do
    output = Components::UI::DropdownMenuSubContent.new.call { "" }
    expect(output).to include('data-wabi--dropdown-menu-target="subPositioner"')
    expect(output).to include('data-wabi--dropdown-menu-target="subContent"')
    expect(output).to match(/data-wabi--dropdown-menu-target="subContent"[^>]*data-state="closed"/)
    expect(output).to match(/data-wabi--dropdown-menu-target="subContent"[^>]*\binert\b/)
  end

  it "composes a menu with a nested submenu containing items + checkboxes" do
    composed = Class.new(Phlex::HTML) do
      def view_template
        render Components::UI::DropdownMenu.new do
          render Components::UI::DropdownMenuTrigger.new { "Open" }
          render Components::UI::DropdownMenuContent.new do
            render Components::UI::DropdownMenuItem.new(value: "edit") { "Edit" }
            render Components::UI::DropdownMenuSub.new do
              render Components::UI::DropdownMenuSubTrigger.new(value: "share") { "Share" }
              render Components::UI::DropdownMenuSubContent.new do
                render Components::UI::DropdownMenuItem.new(value: "email") { "Email" }
                render Components::UI::DropdownMenuCheckboxItem.new(value: "notify_team", checked: true) { "Notify team" }
              end
            end
          end
        end
      end
    end.new.call

    expect(composed).to include('data-wabi--dropdown-menu-target="sub"')
    expect(composed).to include('data-wabi--dropdown-menu-target="subTrigger"')
    expect(composed).to include('data-wabi--dropdown-menu-target="subContent"')
    expect(composed).to include('Share')
    expect(composed).to include('Email')
    expect(composed).to include('Notify team')
    # CheckboxItem inside a sub still uses `optionItem` target -- the
    # controller routes by closest sub ancestor at render time.
    expect(composed).to include('data-wabi--dropdown-menu-target="optionItem"')
  end

  it "composes into a full menu" do
    composed = Class.new(Phlex::HTML) do
      def view_template
        render Components::UI::DropdownMenu.new do
          render Components::UI::DropdownMenuTrigger.new { "Open menu" }
          render Components::UI::DropdownMenuContent.new do
            render Components::UI::DropdownMenuLabel.new { "Actions" }
            render Components::UI::DropdownMenuItem.new(value: "edit")    { "Edit" }
            render Components::UI::DropdownMenuItem.new(value: "duplicate") { "Duplicate" }
            render Components::UI::DropdownMenuSeparator.new
            render Components::UI::DropdownMenuItem.new(value: "delete")  { "Delete" }
          end
        end
      end
    end.new.call

    expect(composed).to include('data-controller="wabi--dropdown-menu"')
    expect(composed).to include('data-wabi--dropdown-menu-target="trigger"')
    expect(composed).to include('data-wabi--dropdown-menu-target="content"')
    expect(composed).to include("Edit")
    expect(composed).to include("Delete")
  end
end
