# frozen_string_literal: true

require "wabi"
require_relative "date_picker_view"
require_relative "calendar"

RSpec.describe "Date Picker" do
  describe "Calendar (inline)" do
    it "wires the controller + core data-values" do
      out = Components::UI::Calendar.new(name: "event[date]").call
      expect(out).to include('data-controller="wabi--date-picker"')
      expect(out).to include('data-wabi--date-picker-name-value="event[date]"')
      expect(out).to include('data-wabi--date-picker-selection-mode-value="single"')
      expect(out).to include('data-wabi--date-picker-locale-value="en-US"')
    end

    it "renders the view-control row + an empty grid the controller fills" do
      out = Components::UI::Calendar.new(name: "d").call
      expect(out).to include('data-wabi--date-picker-target="prev"')
      expect(out).to include('data-wabi--date-picker-target="next"')
      expect(out).to include('data-wabi--date-picker-target="viewTrigger"')
      expect(out).to include('data-wabi--date-picker-target="gridHead"')
      expect(out).to include('data-wabi--date-picker-target="grid"')
      expect(out).not_to include('data-wabi--date-picker-target="input"')
    end

    it "single mode emits one hidden input named after :name" do
      out = Components::UI::Calendar.new(name: "event[date]").call
      expect(out).to match(/<input[^>]*type="hidden"[^>]*name="event\[date\]"[^>]*data-wabi--date-picker-target="hiddenStart"/)
      expect(out).not_to include('data-wabi--date-picker-target="hiddenEnd"')
    end

    it "range mode emits [start] + [end] hidden inputs and defaults to 2 months" do
      out = Components::UI::Calendar.new(name: "stay", selection_mode: :range).call
      expect(out).to include('data-wabi--date-picker-selection-mode-value="range"')
      expect(out).to include('data-wabi--date-picker-num-of-months-value="2"')
      expect(out).to include('name="stay[start]"')
      expect(out).to include('name="stay[end]"')
    end

    it "serializes default_value + min/max as ISO strings" do
      out = Components::UI::Calendar.new(name: "d", default_value: "2026-06-05", min: "2026-01-01", max: "2026-12-31").call
      expect(out).to include('data-wabi--date-picker-default-value-value="2026-06-05"')
      expect(out).to include('data-wabi--date-picker-min-value="2026-01-01"')
      expect(out).to include('data-wabi--date-picker-max-value="2026-12-31"')
    end

    it "serializes Date objects as ISO strings" do
      out = Components::UI::Calendar.new(name: "d", default_value: Date.new(2026, 6, 5), min: Date.new(2026, 1, 1)).call
      expect(out).to include('data-wabi--date-picker-default-value-value="2026-06-05"')
      expect(out).to include('data-wabi--date-picker-min-value="2026-01-01"')
    end

    it "casts disabled/readonly booleans to string data-values" do
      out = Components::UI::Calendar.new(name: "d", disabled: true, readonly: true).call
      expect(out).to include('data-wabi--date-picker-disabled-value="true"')
      expect(out).to include('data-wabi--date-picker-readonly-value="true"')
    end

    it "forwards arbitrary attrs + merges class on the root" do
      out = Components::UI::Calendar.new(name: "d", class: "shadow-lg", id: "cal1").call
      expect(out).to include('id="cal1"')
      expect(out).to include("shadow-lg")
    end
  end
end
