# frozen_string_literal: true

require "wabi"
require_relative "dropdown_menu"
require_relative "dropdown_menu_trigger"
require_relative "dropdown_menu_content"
require_relative "dropdown_menu_item"
require_relative "dropdown_menu_label"
require_relative "dropdown_menu_separator"
require_relative "dropdown_menu_shortcut"

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

  it "DropdownMenuContent starts hidden on content, NOT on positioner" do
    output = Components::UI::DropdownMenuContent.new.call { "" }
    expect(output).to include('data-wabi--dropdown-menu-target="positioner"')
    expect(output).to include('data-wabi--dropdown-menu-target="content"')
    expect(output).to match(/data-wabi--dropdown-menu-target="content"[^>]*hidden/)
    expect(output).not_to match(/data-wabi--dropdown-menu-target="positioner"[^>]*hidden/)
  end

  it "DropdownMenuItem emits role=menuitem with value + disabled data attrs" do
    output = Components::UI::DropdownMenuItem.new(value: "edit").call { "Edit" }
    expect(output).to include('role="menuitem"')
    expect(output).to include('data-wabi--dropdown-menu-target="item"')
    expect(output).to include('data-wabi-value="edit"')
    expect(output).to include('data-wabi-disabled="false"')
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
