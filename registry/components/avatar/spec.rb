# frozen_string_literal: true

require "wabi"
require_relative "avatar"
require_relative "avatar_image"
require_relative "avatar_fallback"

RSpec.describe "Avatar composition" do
  it "renders Avatar wrapper as span with rounded-full and overflow-hidden" do
    output = Components::UI::Avatar.new.call { "x" }
    expect(output).to include("<span")
    expect(output).to include("rounded-full")
    expect(output).to include("overflow-hidden")
  end

  it "renders AvatarImage with src and alt" do
    output = Components::UI::AvatarImage.new(src: "/me.png", alt: "Me").call
    expect(output).to include('src="/me.png"')
    expect(output).to include('alt="Me"')
  end

  it "renders AvatarFallback with bg-muted and initials" do
    output = Components::UI::AvatarFallback.new.call { "OO" }
    expect(output).to include("bg-muted")
    expect(output).to include(">OO</span>")
  end
end
