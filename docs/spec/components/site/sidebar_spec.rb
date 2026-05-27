# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Site::Sidebar do
  def render_to_html(component)
    component.call
  end

  it "renders 7 groups in declared order" do
    html = render_to_html(described_class.new(current_path: "/"))
    expected_labels = ["Getting Started", "Forms", "Layout & Display", "Overlays", "Menus", "Navigation", "Feedback"]
    expected_labels.each { |label| expect(html).to include(label) }
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
