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

  it "renders CardDescription as p with text-muted-foreground" do
    output = Components::UI::CardDescription.new.call { "Desc" }
    expect(output).to include("<p")
    expect(output).to include("text-muted-foreground")
    expect(output).to include(">Desc</p>")
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
