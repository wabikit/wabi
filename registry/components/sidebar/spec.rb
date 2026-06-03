# frozen_string_literal: true

require "wabi"
require_relative "sidebar_provider"
require_relative "sidebar"
require_relative "sidebar_header"
require_relative "sidebar_content"
require_relative "sidebar_footer"
require_relative "sidebar_group"
require_relative "sidebar_group_label"
require_relative "sidebar_menu"
require_relative "sidebar_menu_item"
require_relative "sidebar_menu_button"

RSpec.describe "Sidebar structural pieces" do
  it "SidebarProvider hosts the controller, group marker, default expanded state" do
    out = Components::UI::SidebarProvider.new.call { "" }
    expect(out).to include('data-controller="wabi--sidebar"')
    expect(out).to include("group/sidebar")
    expect(out).to include('data-state="expanded"')
    expect(out).to include('data-mobile="closed"')
    expect(out).to include('data-wabi--sidebar-target="backdrop"')
  end

  it "SidebarProvider can start collapsed and accepts a persist key" do
    out = Components::UI::SidebarProvider.new(default_collapsed: true, persist_key: "app-nav").call { "" }
    expect(out).to include('data-state="collapsed"')
    expect(out).to include('data-wabi--sidebar-default-collapsed-value="true"')
    expect(out).to include('data-wabi--sidebar-persist-key-value="app-nav"')
  end

  it "Sidebar renders an aside panel; side: :left borders right, :right borders left" do
    left  = Components::UI::Sidebar.new.call { "" }
    right = Components::UI::Sidebar.new(side: :right).call { "" }
    expect(left).to include("<aside")
    expect(left).to include('data-wabi--sidebar-target="panel"')
    expect(left).to include("border-r")
    expect(left).to include("-translate-x-full")
    expect(right).to include("border-l")
    expect(right).to include("group-data-[state=collapsed]/sidebar:lg:w-[3.25rem]")
  end

  it "Sections render with their layout roles" do
    expect(Components::UI::SidebarHeader.new.call { "" }).to include("<div")
    expect(Components::UI::SidebarContent.new.call { "" }).to include("overflow-auto")
    expect(Components::UI::SidebarFooter.new.call { "" }).to include("<div")
  end

  it "Group + GroupLabel render; the label collapses away in icon mode" do
    expect(Components::UI::SidebarGroup.new.call { "" }).to include("<div")
    label = Components::UI::SidebarGroupLabel.new.call { "Platform" }
    expect(label).to include("Platform")
    expect(label).to include("group-data-[state=collapsed]/sidebar:opacity-0")
  end

  it "Menu renders a ul, MenuItem a li" do
    expect(Components::UI::SidebarMenu.new.call { "" }).to include("<ul")
    expect(Components::UI::SidebarMenuItem.new.call { "" }).to include("<li")
  end

  it "forwards user class on the provider" do
    expect(Components::UI::SidebarProvider.new(class: "h-dvh").call { "" }).to include("h-dvh")
  end

  it "SidebarMenuButton renders an anchor when href is given, marked active" do
    out = Components::UI::SidebarMenuButton.new(href: "/dashboard", active: true).call { "Dash" }
    expect(out).to include("<a")
    expect(out).to include('href="/dashboard"')
    expect(out).to include('aria-current="page"')
    expect(out).to include("bg-accent")
    expect(out).to include("Dash")
  end

  it "SidebarMenuButton renders a button when no href, not active" do
    out = Components::UI::SidebarMenuButton.new.call { "Action" }
    expect(out).to include('<button')
    expect(out).to include('type="button"')
    expect(out).not_to include('aria-current="page"')
  end

  it "SidebarMenuButton hides its label span in collapsed (icon) mode" do
    out = Components::UI::SidebarMenuButton.new(href: "/x").call { "Label" }
    expect(out).to include("group-data-[state=collapsed]/sidebar:[&>span]:hidden")
  end
end
