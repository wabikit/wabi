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

    it "places the toaster per the placement option (default top_right)" do
      output = described_class.new.call
      expect(output).to include("top-4")
      expect(output).to include("right-4")
    end

    it "supports bottom_center placement" do
      output = described_class.new(placement: :bottom_center).call
      expect(output).to include("bottom-4")
      expect(output).to include("left-1/2")
    end

    it "is `pointer-events-none` so the empty toaster doesn't block clicks behind it" do
      output = described_class.new.call
      expect(output).to include("pointer-events-none")
    end
  end

  describe Components::UI::Toast do
    it "renders an <li role=status aria-live=polite> with the controller wired" do
      output = described_class.new(title: "Saved").call
      expect(output).to include('<li')
      expect(output).to include('role="status"')
      expect(output).to include('aria-live="polite"')
      expect(output).to include('data-controller="wabi--toast"')
    end

    it "carries the duration in ms as a Stimulus Number value" do
      output = described_class.new(title: "Saved", duration_ms: 2000).call
      expect(output).to include('data-wabi--toast-duration-ms-value="2000"')
    end

    it "renders the title and optional description" do
      output = described_class.new(title: "Saved", description: "Profile updated successfully").call
      expect(output).to include("Saved")
      expect(output).to include("Profile updated successfully")
    end

    it "renders a dismiss button wired to the controller#dismiss action" do
      output = described_class.new(title: "Saved").call
      expect(output).to include('aria-label="Dismiss"')
      expect(output).to include('data-action="click->wabi--toast#dismiss"')
    end

    it "applies the appearance variant" do
      output = described_class.new(title: "Boom", appearance: :destructive).call
      expect(output).to include("bg-destructive")
      expect(output).to include("text-destructive-foreground")
    end

    it "the toast is `pointer-events-auto` to override the toaster's `pointer-events-none`" do
      output = described_class.new(title: "Hello").call
      expect(output).to include("pointer-events-auto")
    end
  end
end
