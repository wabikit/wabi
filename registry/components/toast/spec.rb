# frozen_string_literal: true

require "wabi"
require_relative "toaster"
require_relative "toast"

RSpec.describe "Toast composition" do
  describe Components::UI::Toaster do
    it "renders a singleton <ol> region with default id wabi-toaster" do
      output = described_class.new.call
      expect(output).to include('<ol')
      expect(output).to include('id="wabi-toaster"')
      expect(output).to include('role="region"')
      expect(output).to include('aria-label="Notifications"')
    end

    it "wires the wabi--toast controller and group-machine values" do
      output = described_class.new(max: 3, gap: 24, placement: "top-end").call
      expect(output).to include('data-controller="wabi--toast"')
      expect(output).to include('data-wabi--toast-max-value="3"')
      expect(output).to include('data-wabi--toast-gap-value="24"')
      expect(output).to include('data-wabi--toast-placement-value="top-end"')
    end

    it "includes a <template> target with the toast skeleton" do
      output = described_class.new.call
      expect(output).to include('data-wabi--toast-target="template"')
      expect(output).to include('<template')
      expect(output).to include('data-slot="title"')
      expect(output).to include('data-slot="description"')
      expect(output).to include('data-slot="close"')
    end

    it "is pointer-events-none so the empty toaster doesn't block clicks" do
      output = described_class.new.call
      expect(output).to include("pointer-events-none")
    end
  end

  describe Components::UI::Toast do
    it "renders an inert SSR <li> for first-page-load toasts (no controller)" do
      output = described_class.new(title: "Saved").call
      expect(output).to include('<li')
      expect(output).to include('role="status"')
      expect(output).to include('aria-live="polite"')
      expect(output).not_to include('data-controller=')
    end

    it "renders the title and optional description" do
      output = described_class.new(title: "Saved", description: "Profile updated").call
      expect(output).to include("Saved")
      expect(output).to include("Profile updated")
    end

    it "applies the appearance variant class" do
      output = described_class.new(title: "Boom", appearance: :destructive).call
      expect(output).to include("bg-destructive")
    end
  end
end
