# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Site::Sidebar do
  def render_to_html(component)
    component.call
  end

  it "renders all 7 groups in declared order" do
    html = render_to_html(described_class.new(current_path: "/"))
    labels = ["Getting Started", "Forms", "Layout & Display", "Overlays", "Menus", "Navigation", "Feedback"]
    indices = labels.map { |l| html.index(l) }
    expect(indices).to all(be_a(Integer)), "Missing labels: #{labels.zip(indices).reject { |_, i| i }.map(&:first).inspect}"
    expect(indices).to eq(indices.sort), "Labels rendered out of order: expected #{labels}, got positions #{indices}"
  end

  it "lists Number Input under Forms (linking to its docs page)" do
    html = render_to_html(described_class.new(current_path: "/"))
    expect(html).to match(%r{<a[^>]*href="/docs/components/number_input"[^>]*>.*?Number Input}m)
  end

  it "marks the matching link with aria-current=\"page\"" do
    html = render_to_html(described_class.new(current_path: "/docs/components/checkbox"))
    expect(html).to match(%r{<a[^>]*href="/docs/components/checkbox"[^>]*aria-current="page"})
  end

  it "does NOT mark non-matching links with aria-current" do
    html = render_to_html(described_class.new(current_path: "/docs/components/checkbox"))
    expect(html).not_to match(%r{<a[^>]*href="/docs/components/button"[^>]*aria-current="page"})
  end

  it "is hidden below the lg breakpoint" do
    html = render_to_html(described_class.new(current_path: "/"))
    expect(html).to match(%r{<aside[^>]*class="[^"]*hidden lg:block})
  end
end
