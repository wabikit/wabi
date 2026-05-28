# frozen_string_literal: true

require "wabi"
require_relative "command"
require_relative "command_trigger"
require_relative "command_dialog"
require_relative "command_input"
require_relative "command_list"
require_relative "command_group"
require_relative "command_item"
require_relative "command_empty"

RSpec.describe "Command composition" do
  describe Components::UI::Command do
    it "renders a div wired to BOTH the wabi--dialog and wabi--command controllers" do
      output = described_class.new.call
      expect(output).to include('<div')
      expect(output).to include('data-controller="wabi--dialog wabi--command"')
    end

    it "modal=true is forced on the dialog (command is always a modal palette)" do
      output = described_class.new.call
      expect(output).to include('data-wabi--dialog-modal-value="true"')
    end
  end

  describe Components::UI::CommandTrigger do
    it "renders a button wired to the dialog trigger target" do
      output = described_class.new.call { "Search... ⌘K" }
      expect(output).to include('<button')
      expect(output).to include('data-wabi--dialog-target="trigger"')
      expect(output).to include("Search... ⌘K")
    end
  end

  describe Components::UI::CommandDialog do
    it "renders dialog content with the wabi--combobox controller nested" do
      output = described_class.new.call
      expect(output).to include('data-wabi--dialog-target="content"')
      expect(output).to include('data-controller="wabi--combobox"')
      expect(output).to include('data-wabi--combobox-portal-value="false"')
    end
  end

  describe Components::UI::CommandInput do
    it "renders an <input> wired as the combobox input target" do
      output = described_class.new(placeholder: "Type a command...").call
      expect(output).to include('<input')
      expect(output).to include('data-wabi--combobox-target="input"')
      expect(output).to include('placeholder="Type a command..."')
    end
  end

  describe Components::UI::CommandItem do
    it "renders an <li> wired as the combobox item with the value + label" do
      output = described_class.new(value: "new_file").call { "New File" }
      expect(output).to include('<li')
      expect(output).to include('data-wabi--combobox-target="item"')
      expect(output).to include('data-wabi-value="new_file"')
      expect(output).to include("New File")
    end
  end

  describe Components::UI::CommandEmpty do
    it "renders an empty-state slot" do
      output = described_class.new.call { "No results found." }
      expect(output).to include('data-wabi-command-empty')
      expect(output).to include("No results found.")
    end
  end
end
