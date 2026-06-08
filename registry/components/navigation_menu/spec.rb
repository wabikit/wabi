# frozen_string_literal: true

require "wabi"
require_relative "navigation_menu"
require_relative "navigation_menu_list"
require_relative "navigation_menu_item"
require_relative "navigation_menu_trigger"
require_relative "navigation_menu_content"
require_relative "navigation_menu_link"

RSpec.describe "NavigationMenu composition" do
  describe Components::UI::NavigationMenu do
    it "renders a <nav> wired to the wabi--navigation-menu controller" do
      output = described_class.new.call
      expect(output).to include('data-controller="wabi--navigation-menu"')
    end

    it "serializes orientation" do
      output = described_class.new(orientation: :vertical).call
      expect(output).to include('data-wabi--navigation-menu-orientation-value="vertical"')
    end

    it "yields its block" do
      expect(described_class.new.call { "INNER" }).to include("INNER")
    end

    it "omits aria-label when not provided (default nil)" do
      output = described_class.new.call
      expect(output).not_to include("aria-label")
    end

    it "passes aria_label onto the <nav> element" do
      output = described_class.new(aria_label: "Main navigation").call
      expect(output).to include('aria-label="Main navigation"')
    end
  end

  describe Components::UI::NavigationMenuList do
    it "renders the list and yields" do
      output = described_class.new.call { "ITEMS" }
      expect(output).to include('data-wabi--navigation-menu-target="list"')
      expect(output).to include("ITEMS")
    end
    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--navigation-menu-target="list"')
    end
  end

  describe Components::UI::NavigationMenuItem do
    it "renders an item carrying its value" do
      output = described_class.new(value: "products").call { "X" }
      expect(output).to include('data-wabi--navigation-menu-target="item"')
      expect(output).to include('data-wabi-value="products"')
    end
    it "renders without a block" do
      expect(described_class.new(value: "products").call).to include('data-wabi-value="products"')
    end
  end

  describe Components::UI::NavigationMenuTrigger do
    it "renders a trigger carrying its value" do
      output = described_class.new(value: "products").call { "Products" }
      expect(output).to include('data-wabi--navigation-menu-target="trigger"')
      expect(output).to include('data-wabi-value="products"')
      expect(output).to include("Products")
    end
    it "renders without a block" do
      expect(described_class.new(value: "products").call).to include('data-wabi-value="products"')
    end
  end

  describe Components::UI::NavigationMenuContent do
    it "renders content carrying its value" do
      output = described_class.new(value: "products").call { "Body" }
      expect(output).to include('data-wabi--navigation-menu-target="content"')
      expect(output).to include('data-wabi-value="products"')
      expect(output).to include("Body")
    end
    it "renders without a block" do
      expect(described_class.new(value: "products").call).to include('data-wabi-value="products"')
    end
  end

  describe Components::UI::NavigationMenuLink do
    it "renders a link carrying its value" do
      output = described_class.new(value: "products", href: "/p").call { "Go" }
      expect(output).to include('data-wabi--navigation-menu-target="link"')
      expect(output).to include('data-wabi-value="products"')
      expect(output).to include('href="/p"')
    end
    it "renders without a block" do
      expect(described_class.new(value: "products", href: "/p").call).to include('data-wabi--navigation-menu-target="link"')
    end
  end
end
