# frozen_string_literal: true

require "wabi"
require_relative "carousel"
require_relative "carousel_item_group"
require_relative "carousel_item"
require_relative "carousel_control"
require_relative "carousel_prev_trigger"
require_relative "carousel_next_trigger"
require_relative "carousel_indicator_group"
require_relative "carousel_indicator"

RSpec.describe "Carousel composition" do
  describe Components::UI::Carousel do
    it "renders a <div> wired to the wabi--carousel controller" do
      output = described_class.new(slide_count: 3).call
      expect(output).to include('data-controller="wabi--carousel"')
    end

    it "serializes slide_count and config" do
      output = described_class.new(slide_count: 5, slides_per_page: 2, slides_per_move: 3, loop: true, orientation: :vertical, autoplay: true).call
      expect(output).to include('data-wabi--carousel-slide-count-value="5"')
      expect(output).to include('data-wabi--carousel-slides-per-page-value="2"')
      expect(output).to include('data-wabi--carousel-slides-per-move-value="3"')
      expect(output).to include('data-wabi--carousel-loop-value="true"')
      expect(output).to include('data-wabi--carousel-orientation-value="vertical"')
      expect(output).to include('data-wabi--carousel-autoplay-value="true"')
    end

    it "yields its block" do
      output = described_class.new(slide_count: 3).call { "INNER" }
      expect(output).to include("INNER")
    end

    it "renders a visually-hidden live-region announcer for screen readers (a11y fix)" do
      output = described_class.new(slide_count: 3).call
      expect(output).to include('role="status"')
      expect(output).to include('aria-live="polite"')
      expect(output).to include('aria-atomic="true"')
      expect(output).to include('data-wabi--carousel-target="announcer"')
      expect(output).to include('class="sr-only"')
    end
  end

  describe Components::UI::CarouselItem do
    it "renders an indexed slide" do
      output = described_class.new(index: 2).call { "Slide" }
      expect(output).to include('data-wabi--carousel-target="item"')
      expect(output).to include('data-wabi-index="2"')
      expect(output).to include("Slide")
    end

    it "renders without a block" do
      expect(described_class.new(index: 0).call).to include('data-wabi-index="0"')
    end
  end

  describe Components::UI::CarouselIndicator do
    it "renders an indexed indicator" do
      output = described_class.new(index: 1).call
      expect(output).to include('data-wabi--carousel-target="indicator"')
      expect(output).to include('data-wabi-index="1"')
    end
    it "includes focus-visible ring classes (a11y fix)" do
      output = described_class.new(index: 0).call
      expect(output).to include("focus-visible:ring-2")
      expect(output).to include("focus-visible:ring-ring")
      expect(output).to include("focus-visible:ring-offset-2")
      expect(output).to include("focus-visible:outline-none")
    end
  end

  describe Components::UI::CarouselItemGroup do
    it "renders the item group and yields" do
      output = described_class.new.call { "SLIDES" }
      expect(output).to include('data-wabi--carousel-target="itemGroup"')
      expect(output).to include("SLIDES")
    end

    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--carousel-target="itemGroup"')
    end
  end

  describe Components::UI::CarouselControl do
    it "renders the control region and yields" do
      output = described_class.new.call { "CTRL" }
      expect(output).to include('data-wabi--carousel-target="control"')
      expect(output).to include("CTRL")
    end

    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--carousel-target="control"')
    end
  end

  describe Components::UI::CarouselPrevTrigger do
    it "renders a prev button" do
      expect(described_class.new.call { "‹" }).to include('data-wabi--carousel-target="prevTrigger"')
    end
    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--carousel-target="prevTrigger"')
    end
    it "includes focus-visible ring classes (a11y fix)" do
      output = described_class.new.call
      expect(output).to include("focus-visible:ring-2")
      expect(output).to include("focus-visible:ring-ring")
      expect(output).to include("focus-visible:ring-offset-2")
      expect(output).to include("focus-visible:outline-none")
    end
  end

  describe Components::UI::CarouselNextTrigger do
    it "renders a next button" do
      expect(described_class.new.call { "›" }).to include('data-wabi--carousel-target="nextTrigger"')
    end
    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--carousel-target="nextTrigger"')
    end
    it "includes focus-visible ring classes (a11y fix)" do
      output = described_class.new.call
      expect(output).to include("focus-visible:ring-2")
      expect(output).to include("focus-visible:ring-ring")
      expect(output).to include("focus-visible:ring-offset-2")
      expect(output).to include("focus-visible:outline-none")
    end
  end

  describe Components::UI::CarouselIndicatorGroup do
    it "renders the indicator group and yields" do
      output = described_class.new.call { "DOTS" }
      expect(output).to include('data-wabi--carousel-target="indicatorGroup"')
      expect(output).to include("DOTS")
    end
    it "renders without a block" do
      expect(described_class.new.call).to include('data-wabi--carousel-target="indicatorGroup"')
    end
  end
end
