# frozen_string_literal: true

require "wabi"
require_relative "date_picker_view"
require_relative "calendar"
require_relative "date_picker"

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

  describe "DatePicker (field)" do
    it "renders control > input + trigger, sharing the controller" do
      out = Components::UI::DatePicker.new(name: "event[date]").call
      expect(out).to include('data-controller="wabi--date-picker"')
      expect(out).to include('data-wabi--date-picker-target="control"')
      expect(out).to include('data-wabi--date-picker-target="input"')
      expect(out).to include('data-wabi--date-picker-target="trigger"')
    end

    it "renders a portaled positioner + content (content starts hidden + inert + closed)" do
      out = Components::UI::DatePicker.new(name: "d").call
      expect(out).to include('data-wabi--date-picker-target="positioner"')
      expect(out).to match(/data-wabi--date-picker-target="content"[^>]*data-state="closed"/)
      expect(out).to match(/data-wabi--date-picker-target="content"[^>]*\binert\b/)
      expect(out).to match(/data-wabi--date-picker-target="content"[^>]*\bhidden\b/)
      expect(out).not_to match(/data-wabi--date-picker-target="positioner"[^>]*\bhidden\b/)
    end

    it "carries portal-value true by default and honors portal: false" do
      expect(Components::UI::DatePicker.new(name: "d").call).to include('data-wabi--date-picker-portal-value="true"')
      expect(Components::UI::DatePicker.new(name: "d", portal: false).call).to include('data-wabi--date-picker-portal-value="false"')
    end

    it "supports motion-reduce on the content" do
      expect(Components::UI::DatePicker.new(name: "d").call).to include("motion-reduce:transition-none")
    end

    it "passes through a placeholder to the input" do
      out = Components::UI::DatePicker.new(name: "d", placeholder: "Pick a date").call
      expect(out).to include('placeholder="Pick a date"')
    end

    it "forwards id + arbitrary data attrs without clobbering the controller wiring" do
      out = Components::UI::DatePicker.new(name: "d", id: "dp1", data: { testid: "picker" }).call
      expect(out).to include('id="dp1"')
      expect(out).to include('data-testid="picker"')
      expect(out).to include('data-controller="wabi--date-picker"')
    end
  end
end
