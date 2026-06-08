# frozen_string_literal: true

require "wabi"
require_relative "card"
require_relative "card_header"
require_relative "card_title"
require_relative "card_description"
require_relative "card_content"
require_relative "card_footer"

RSpec.describe Components::UI::Card do
  it "renders a div with rounded-lg, bg-card, text-card-foreground" do
    output = described_class.new.call
    expect(output).to include("<div")
    expect(output).to include("rounded-lg")
    expect(output).to include("bg-card")
    expect(output).to include("text-card-foreground")
  end

  it "renders CardTitle as h3 with text-2xl" do
    output = Components::UI::CardTitle.new.call { "Title" }
    expect(output).to include("<h3")
    expect(output).to include("text-2xl")
    expect(output).to include(">Title</h3>")
  end

  it "CardTitle respects level: keyword — emits the matching heading tag" do
    expect(Components::UI::CardTitle.new(level: 2).call { "T" }).to include("<h2")
    expect(Components::UI::CardTitle.new(level: 2).call { "T" }).to include(">T</h2>")
    expect(Components::UI::CardTitle.new(level: 1).call { "T" }).to include("<h1")
    expect(Components::UI::CardTitle.new(level: 3).call { "T" }).to include("<h3") # default unchanged
  end

  it "CardTitle level: defaults to h3 when omitted (no breaking change)" do
    output = Components::UI::CardTitle.new.call { "Default" }
    expect(output).to include("<h3")
    expect(output).to include(">Default</h3>")
  end

  it "renders CardDescription as p with text-muted-foreground" do
    output = Components::UI::CardDescription.new.call { "Desc" }
    expect(output).to include("<p")
    expect(output).to include("text-muted-foreground")
    expect(output).to include(">Desc</p>")
  end

  it "CardContent defaults to with_header padding (px-6 pt-0 pb-6, identical to old p-6 pt-0)" do
    output = Components::UI::CardContent.new.call { "Body" }
    expect(output).to include("px-6")
    expect(output).to include("pt-0")
    expect(output).to include("pb-6")
    expect(output).not_to include("py-6")
  end

  it "CardContent with padding: :standalone uses symmetric vertical padding (px-6 py-6)" do
    output = Components::UI::CardContent.new(padding: :standalone).call { "Body" }
    expect(output).to include("px-6")
    expect(output).to include("py-6")
    expect(output).not_to include("pt-0")
  end

  it "CardContent still forwards user class and html attributes" do
    output = Components::UI::CardContent.new(padding: :standalone, class: "flex gap-3", id: "x").call { "Body" }
    expect(output).to include("flex gap-3")
    expect(output).to include('id="x"')
  end

  it "composes header, title, description, content, footer" do
    composition = Class.new(Phlex::HTML) do
      def view_template
        render Components::UI::Card.new do
          render Components::UI::CardHeader.new do
            render Components::UI::CardTitle.new { "Onboarding" }
            render Components::UI::CardDescription.new { "Complete your profile." }
          end
          render Components::UI::CardContent.new do
            p { "Body content here." }
          end
          render Components::UI::CardFooter.new do
            p { "Footer here." }
          end
        end
      end
    end

    output = composition.new.call
    expect(output).to include("Onboarding")
    expect(output).to include("Complete your profile.")
    expect(output).to include("Body content here.")
    expect(output).to include("Footer here.")
  end
end
