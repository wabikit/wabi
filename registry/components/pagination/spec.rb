# frozen_string_literal: true

require "wabi"
require_relative "pagination"
require_relative "pagination_content"
require_relative "pagination_item"
require_relative "pagination_link"
require_relative "pagination_previous"
require_relative "pagination_next"
require_relative "pagination_ellipsis"

RSpec.describe Components::UI::Pagination do
  it "renders a nav labelled pagination" do
    output = described_class.new.call
    expect(output).to include("<nav")
    expect(output).to include('aria-label="pagination"')
    expect(output).to include('role="navigation"')
  end

  it "renders PaginationContent as a ul" do
    output = Components::UI::PaginationContent.new.call { "x" }
    expect(output).to include("<ul")
    expect(output).to include("flex-row")
  end

  it "renders an inactive PaginationLink as a ghost anchor" do
    output = Components::UI::PaginationLink.new(href: "/p/2").call { "2" }
    expect(output).to include("<a")
    expect(output).to include('href="/p/2"')
    expect(output).to include("hover:bg-accent")
    expect(output).not_to include('aria-current')
  end

  it "marks an active PaginationLink with aria-current and outline" do
    output = Components::UI::PaginationLink.new(active: true, href: "/p/1").call { "1" }
    expect(output).to include('aria-current="page"')
    expect(output).to include("border")
  end

  it "renders PaginationPrevious with a label and chevron" do
    output = Components::UI::PaginationPrevious.new(href: "/p/1").call
    expect(output).to include('aria-label="Go to previous page"')
    expect(output).to include("Previous")
    expect(output).to include("<svg")
  end

  it "renders PaginationNext with a label and chevron" do
    output = Components::UI::PaginationNext.new(href: "/p/3").call
    expect(output).to include('aria-label="Go to next page"')
    expect(output).to include("Next")
  end

  it "renders PaginationEllipsis with an sr-only label" do
    output = Components::UI::PaginationEllipsis.new.call
    expect(output).to include('aria-hidden="true"')
    expect(output).to include("sr-only")
  end
end
