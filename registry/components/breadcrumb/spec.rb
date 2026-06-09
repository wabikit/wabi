# frozen_string_literal: true

require "wabi"
require_relative "breadcrumb"
require_relative "breadcrumb_list"
require_relative "breadcrumb_item"
require_relative "breadcrumb_link"
require_relative "breadcrumb_page"
require_relative "breadcrumb_separator"
require_relative "breadcrumb_ellipsis"

RSpec.describe Components::UI::Breadcrumb do
  it "renders a nav labelled breadcrumb" do
    output = described_class.new.call
    expect(output).to include("<nav")
    expect(output).to include('aria-label="breadcrumb"')
  end

  # Regression: a base-class-less root that calls merge_class(user_class) with
  # no :class must NOT emit a spurious empty class="" attribute (ClassMerge
  # returns nil for an empty merge so Phlex omits the attribute).
  it "omits the class attribute when no class is passed" do
    output = described_class.new.call
    expect(output).not_to include('class=""')
  end

  it "renders BreadcrumbList as an ol" do
    output = Components::UI::BreadcrumbList.new.call { "x" }
    expect(output).to include("<ol")
    expect(output).to include("items-center")
  end

  it "renders BreadcrumbLink as a hover-able anchor" do
    output = Components::UI::BreadcrumbLink.new(href: "/").call { "Home" }
    expect(output).to include("<a")
    expect(output).to include('href="/"')
    expect(output).to include("hover:text-foreground")
    expect(output).to include(">Home</a>")
  end

  it "renders BreadcrumbPage as the current-page span" do
    output = Components::UI::BreadcrumbPage.new.call { "Current" }
    expect(output).to include("<span")
    expect(output).to include('aria-current="page"')
    expect(output).to include(">Current</span>")
  end

  # Regression: BreadcrumbPage must NOT carry role="link" or aria-disabled —
  # the current-page crumb is not navigable and should expose only aria-current="page".
  it "BreadcrumbPage has no role=link and no aria-disabled (WCAG roles-semantics fix)" do
    output = Components::UI::BreadcrumbPage.new.call { "Current" }
    expect(output).not_to include('role="link"')
    expect(output).not_to include("aria-disabled")
    expect(output).to include('aria-current="page"')
  end

  it "renders BreadcrumbSeparator with a default chevron svg and aria-hidden" do
    output = Components::UI::BreadcrumbSeparator.new.call
    expect(output).to include("<li")
    expect(output).to include('aria-hidden="true"')
    expect(output).to include("<svg")
  end

  it "renders BreadcrumbEllipsis with an sr-only label" do
    output = Components::UI::BreadcrumbEllipsis.new.call
    expect(output).to include('aria-hidden="true"')
    expect(output).to include("sr-only")
  end
end
