# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Site::ComponentPreview do
  def render_to_html(&block)
    described_class.new(source: "Components::UI::Button.new").call(&block)
  end

  it "renders the minimalist underline Preview/Code switcher look" do
    html = render_to_html { "PREVIEW BODY" }
    expect(html).to include("Preview")
    expect(html).to include("Code")
    expect(html).to include("border-b-[3px]")
    expect(html).to include("aria-selected:border-b-primary")
    expect(html).to include("PREVIEW BODY")
  end

  # Regression: the ComponentPreview wraps every example on the docs site. If its
  # own Tabs root carries data-variant="underline", Tailwind's named group
  # (group/tabs) matches ANY ancestor, so every example Tabs nested inside it
  # inherits the underline variant — making :standard and :pill examples all look
  # underline. The wrapper must NOT be a variant=underline group; it applies the
  # underline look via plain classes while staying the default (standard) variant.
  it "does not expose a variant=underline Tabs group that leaks into nested example tabs" do
    html = render_to_html { "PREVIEW BODY" }
    expect(html).not_to include('data-variant="underline"')
  end
end
