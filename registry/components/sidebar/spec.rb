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
require_relative "sidebar_trigger"
require_relative "../tooltip/tooltip_content"
require_relative "sidebar_menu_collapsible"
require_relative "sidebar_menu_sub"
require_relative "sidebar_menu_sub_item"
require_relative "sidebar_menu_sub_button"
require_relative "sidebar_menu_badge"
require_relative "sidebar_menu_action"
require_relative "sidebar_inset"
require_relative "sidebar_input"
require_relative "sidebar_menu_skeleton"
require_relative "sidebar_rail"

RSpec.describe "Sidebar structural pieces" do
  it "SidebarProvider defaults to the sidebar variant" do
    out = Components::UI::SidebarProvider.new.call { "" }
    expect(out).to include('data-variant="sidebar"')
    expect(out).not_to include("bg-sidebar")
  end

  it "SidebarProvider inset variant sets data-variant + a sidebar background" do
    out = Components::UI::SidebarProvider.new(variant: :inset).call { "" }
    expect(out).to include('data-variant="inset"')
    expect(out).to include("bg-sidebar")
  end

  it "Sidebar carries gated floating + inset adaptations" do
    out = Components::UI::Sidebar.new.call { "" }
    expect(out).to include("group-data-[variant=floating]/sidebar:rounded-lg")
    expect(out).to include("group-data-[variant=floating]/sidebar:shadow-lg")
    expect(out).to include("group-data-[variant=inset]/sidebar:bg-transparent")
  end

  it "SidebarInset is a main wrapper with gated inset-card classes" do
    out = Components::UI::SidebarInset.new.call { "" }
    expect(out).to include("<main")
    # grow (not flex-1) so it coexists with flex-col under ClassMerge's minimal dedup
    # (flex-1 and flex-col share the same "flex" key and would evict each other)
    expect(out).to include("grow")
    expect(out).to include("flex-col")
    expect(out).to include("group-data-[variant=inset]/sidebar:rounded-xl")
    expect(out).to include("group-data-[variant=inset]/sidebar:bg-background")
  end

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
    expect(out).to include("bg-sidebar-accent")
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

  it "SidebarTrigger is a button wired to toggle with an aria-label" do
    out = Components::UI::SidebarTrigger.new.call
    expect(out).to include('<button')
    expect(out).to include('data-action="wabi--sidebar#toggle"')
    expect(out).to include('aria-label')
    expect(out).to include("<svg")
  end

  it "SidebarTrigger accepts a custom icon via block (no default svg)" do
    out = Components::UI::SidebarTrigger.new.call { "Custom" }
    expect(out).to include("Custom")
    expect(out).not_to include("<svg")
  end

  it "SidebarMenuButton with a tooltip: wraps in a wabi--tooltip controller, button stays the trigger" do
    out = Components::UI::SidebarMenuButton.new(href: "/x", tooltip: "Dashboard").call { "Dashboard" }
    expect(out).to include('data-controller="wabi--tooltip"')
    expect(out).to include('data-wabi--tooltip-target="trigger"')
    expect(out).to include('data-wabi--tooltip-target="content"')
    # collapsed-only: tooltip content gated on the <html data-wabi-sidebar> marker
    # (works through the Zag portal, unlike a group/sidebar-scoped gate)
    expect(out).to include("[[data-wabi-sidebar=expanded]_&]:hidden")
    expect(out.scan("Dashboard").size).to be >= 2
  end

  it "SidebarMenuButton without a tooltip renders no tooltip controller" do
    out = Components::UI::SidebarMenuButton.new(href: "/x").call { "X" }
    expect(out).not_to include('data-controller="wabi--tooltip"')
  end

  it "SidebarMenuCollapsible renders a details/summary disclosure with label + chevron" do
    out = Components::UI::SidebarMenuCollapsible.new(label: "Projects").call { "" }
    expect(out).to include("<details")
    expect(out).to include("group/collapsible")
    expect(out).to include("<summary")
    expect(out).to include("Projects")
    expect(out).to include("group-[[open]]/collapsible:rotate-90")
    expect(out).to include("[&::-webkit-details-marker]:hidden")
  end

  it "SidebarMenuCollapsible default_open adds the open attribute" do
    expect(Components::UI::SidebarMenuCollapsible.new(label: "P", default_open: true).call { "" }).to include("open")
    expect(Components::UI::SidebarMenuCollapsible.new(label: "P").call { "" }).not_to include("<details open")
  end

  it "SidebarMenuSub is an indented ul hidden in collapsed mode" do
    out = Components::UI::SidebarMenuSub.new.call { "" }
    expect(out).to include("<ul")
    expect(out).to include("border-l")
    expect(out).to include("group-data-[state=collapsed]/sidebar:hidden")
  end

  it "SidebarMenuCollapsible wires the flyout controller" do
    out = Components::UI::SidebarMenuCollapsible.new(label: "Projects").call { "" }
    expect(out).to include('data-controller="wabi--sidebar-flyout"')
  end

  it "SidebarMenuSub carries the flyout-card classes and the inline base" do
    out = Components::UI::SidebarMenuSub.new.call { "" }
    expect(out).to include("border-l")
    expect(out).to include("group-data-[state=collapsed]/sidebar:hidden")
    expect(out).to include("data-[flyout=open]:!fixed")
    expect(out).to include("data-[flyout=open]:bg-sidebar")
    expect(out).to include("data-[flyout=open]:border-l-0")
  end

  it "SidebarMenuCollapsible marks the details for the open/close animation" do
    expect(Components::UI::SidebarMenuCollapsible.new(label: "Projects").call { "" }).to include("wabi-collapsible")
  end

  it "collapsible SidebarGroup marks the details for the animation; non-collapsible does not" do
    expect(Components::UI::SidebarGroup.new(collapsible: true, label: "Platform").call { "" }).to include("wabi-collapsible")
    expect(Components::UI::SidebarGroup.new.call { "" }).not_to include("wabi-collapsible")
  end

  it "SidebarMenuSubItem is a li" do
    expect(Components::UI::SidebarMenuSubItem.new.call { "" }).to include("<li")
  end

  it "SidebarMenuSubButton renders an anchor with active state" do
    out = Components::UI::SidebarMenuSubButton.new(href: "/a", active: true).call { "Alpha" }
    expect(out).to include("<a")
    expect(out).to include('href="/a"')
    expect(out).to include('aria-current="page"')
    expect(out).to include("bg-sidebar-accent")
    expect(out).to include("Alpha")
  end

  it "SidebarMenuSubButton renders a button when no href" do
    out = Components::UI::SidebarMenuSubButton.new.call { "Beta" }
    expect(out).to include('<button')
    expect(out).to include('type="button"')
    expect(out).not_to include('aria-current="page"')
  end

  it "Sidebar uses the dedicated sidebar surface tokens" do
    out = Components::UI::Sidebar.new.call { "" }
    expect(out).to include("bg-sidebar")
    expect(out).to include("text-sidebar-foreground")
    expect(out).to include("border-sidebar-border")
  end

  it "SidebarMenuButton active/hover/ring use sidebar-accent + sidebar-ring" do
    out = Components::UI::SidebarMenuButton.new(href: "/x").call { "X" }
    expect(out).to include("hover:bg-sidebar-accent")
    expect(out).to include("aria-[current=page]:bg-sidebar-accent")
    expect(out).to include("focus-visible:ring-sidebar-ring")
  end

  it "SidebarMenuItem is a hover group + positioning context" do
    expect(Components::UI::SidebarMenuItem.new.call { "" }).to include("group/menu-item")
  end

  it "SidebarMenuBadge is a trailing span hidden in collapsed mode" do
    out = Components::UI::SidebarMenuBadge.new.call { "12" }
    expect(out).to include("<span")
    expect(out).to include("12")
    expect(out).to include("absolute")
    expect(out).to include("group-data-[state=collapsed]/sidebar:hidden")
  end

  it "SidebarMenuAction is a hover-reveal button hidden in collapsed mode, forwarding attrs" do
    out = Components::UI::SidebarMenuAction.new("aria-label": "More").call { "x" }
    expect(out).to include("<button")
    expect(out).to include('type="button"')
    expect(out).to include('aria-label="More"')
    expect(out).to include("opacity-0")
    expect(out).to include("group-hover/menu-item:opacity-100")
    expect(out).to include("group-data-[state=collapsed]/sidebar:hidden")
  end

  it "SidebarGroup stays a div by default (not collapsible)" do
    expect(Components::UI::SidebarGroup.new.call { "" }).to include("<div")
  end

  it "SidebarGroup collapsible renders a details disclosure with the label as summary" do
    out = Components::UI::SidebarGroup.new(collapsible: true, label: "Platform").call { "" }
    expect(out).to include("<details")
    expect(out).to include("group/collapsible-group")
    expect(out).to include("<summary")
    expect(out).to include("Platform")
    expect(out).to include("group-[[open]]/collapsible-group:rotate-90")
    expect(out).to include("open")
  end

  it "SidebarGroup collapsible respects default_open: false" do
    expect(Components::UI::SidebarGroup.new(collapsible: true, label: "P", default_open: false).call { "" }).not_to include("<details open")
  end

  it "SidebarInput is a search input styled for the sidebar, hidden when collapsed" do
    out = Components::UI::SidebarInput.new(placeholder: "Search").call
    expect(out).to include("<input")
    expect(out).to include('type="search"')
    expect(out).to include('placeholder="Search"')
    expect(out).to include("border-sidebar-border")
    expect(out).to include("group-data-[state=collapsed]/sidebar:hidden")
  end

  it "SidebarMenuSkeleton renders pulse bars; show_icon toggles the icon pulse" do
    with_icon = Components::UI::SidebarMenuSkeleton.new.call
    expect(with_icon).to include("animate-pulse")
    expect(with_icon).to include("size-4")
    expect(with_icon).to include("group-data-[state=collapsed]/sidebar:hidden")
    no_icon = Components::UI::SidebarMenuSkeleton.new(show_icon: false).call
    expect(no_icon).not_to include("size-4")
  end

  it "SidebarMenuButton forwards arbitrary attrs to the element" do
    out = Components::UI::SidebarMenuButton.new(href: "/x", id: "nav-home", target: "_blank", data: { turbo_method: "get" }).call { "Home" }
    expect(out).to include('id="nav-home"')
    expect(out).to include('target="_blank"')
    expect(out).to include('data-turbo-method="get"')
  end

  it "SidebarMenuButton with a tooltip keeps BOTH user data and the tooltip trigger target" do
    out = Components::UI::SidebarMenuButton.new(href: "/x", tooltip: "Home", data: { foo: "bar" }).call { "Home" }
    expect(out).to include('data-foo="bar"')
    expect(out).to include('data-wabi--tooltip-target="trigger"')
  end

  it "SidebarMenuSubButton forwards arbitrary attrs to the element" do
    out = Components::UI::SidebarMenuSubButton.new(href: "/x", id: "sub", "aria-label": "Sub").call { "Sub" }
    expect(out).to include('id="sub"')
    expect(out).to include('aria-label="Sub"')
  end

  it "SidebarRail is a desktop-only toggle button with an edge affordance" do
    out = Components::UI::SidebarRail.new.call
    expect(out).to include('<button')
    expect(out).to include('type="button"')
    expect(out).to include('aria-label="Toggle sidebar"')
    expect(out).to include('tabindex="-1"')
    expect(out).to include('data-action="wabi--sidebar#toggle"')
    expect(out).to include("hidden")
    expect(out).to include("lg:flex")
    expect(out).to include("after:bg-sidebar-border")
    expect(out).to include("hover:after:bg-sidebar-ring")
  end

  it "SidebarRail side picks the inner edge + resize cursor" do
    left  = Components::UI::SidebarRail.new(side: :left).call
    right = Components::UI::SidebarRail.new(side: :right).call
    expect(left).to include("right-0")
    expect(left).to include("cursor-w-resize")
    expect(right).to include("left-0")
    expect(right).to include("cursor-e-resize")
  end

  it "SidebarRail forwards attrs and merges user data with the toggle action" do
    out = Components::UI::SidebarRail.new(id: "rail", data: { foo: "bar" }).call
    expect(out).to include('id="rail"')
    expect(out).to include('data-foo="bar"')
    expect(out).to include('data-action="wabi--sidebar#toggle"')
  end
end
