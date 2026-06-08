# frozen_string_literal: true

require "wabi"
require "json"
require_relative "tags_input"
require_relative "tags_input_label"
require_relative "tags_input_control"
require_relative "tags_input_input"
require_relative "tags_input_error"

RSpec.describe "TagsInput composition" do
  describe Components::UI::TagsInput do
    it "renders a <div> wired to the wabi--tags-input controller" do
      output = described_class.new(name: "tags").call
      expect(output).to include('data-controller="wabi--tags-input"')
      expect(output).to include('data-wabi--tags-input-name-value="tags"')
    end

    it "serializes the initial value array, max and editable flag" do
      output = described_class.new(name: "tags", value: %w[ruby rails], max: 5, editable: false).call
      expect(output).to include('data-wabi--tags-input-value-value="[&quot;ruby&quot;,&quot;rails&quot;]"')
      expect(output).to include('data-wabi--tags-input-max-value="5"')
      expect(output).to include('data-wabi--tags-input-editable-value="false"')
    end

    it "renders the control and text input by default" do
      output = described_class.new(name: "tags").call
      expect(output).to include('data-wabi--tags-input-target="control"')
      expect(output).to include('data-wabi--tags-input-target="input"')
    end

    it "yields a custom block in place of the default control" do
      output = described_class.new(name: "tags").call { "CUSTOM" }
      expect(output).to include("CUSTOM")
    end
  end

  describe Components::UI::TagsInputLabel do
    it "targets the label" do
      output = described_class.new.call { "Tags" }
      expect(output).to include('data-wabi--tags-input-target="label"')
      expect(output).to include("Tags")
    end

    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--tags-input-target="label"')
    end
  end

  describe Components::UI::TagsInputControl do
    it "renders the control wrapper and yields" do
      output = described_class.new.call { "INNER" }
      expect(output).to include('data-wabi--tags-input-target="control"')
      expect(output).to include("INNER")
    end

    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--tags-input-target="control"')
    end
  end

  describe Components::UI::TagsInputInput do
    it "renders a text input with placeholder" do
      output = described_class.new(placeholder: "Add…").call
      expect(output).to include('data-wabi--tags-input-target="input"')
      expect(output).to include('placeholder="Add')
    end
  end

  describe Components::UI::TagsInputError do
    it "renders an error slot" do
      output = described_class.new.call { "Required" }
      expect(output).to include('data-wabi--tags-input-target="error"')
      expect(output).to include("Required")
    end

    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--tags-input-target="error"')
    end

    # a11y: error message must be announced by screen readers via a live region
    it "includes role=alert for screen reader announcement (WCAG live-region fix)" do
      output = described_class.new.call { "Too many tags" }
      expect(output).to include('role="alert"')
    end
  end
end
