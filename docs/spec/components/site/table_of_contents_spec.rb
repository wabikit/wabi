# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Site::TableOfContents do
  def render_to_html(component)
    component.call
  end

  it "renders an empty aside with data-controller='site--toc'" do
    html = render_to_html(described_class.new)
    expect(html).to match(%r{<aside[^>]*data-controller="site--toc"})
    expect(html).to match(%r{hidden xl:block})
  end
end
