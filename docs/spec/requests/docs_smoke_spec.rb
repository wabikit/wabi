# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Docs smoke", type: :request do
  describe "chrome: :bare routes" do
    %w[/ /preview].each do |path|
      it "GET #{path} returns 200 with no sidebar" do
        get path
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include('data-controller="site--toc"')
        expect(response.body).not_to match(/aside[^>]*hidden lg:block/)
      end
    end
  end

  describe "chrome: :sidebar_only routes" do
    %w[/docs/themes /docs/components].each do |path|
      it "GET #{path} returns 200 with sidebar but no TOC" do
        get path
        expect(response).to have_http_status(:ok)
        expect(response.body).to match(/aside[^>]*hidden lg:block/)
        expect(response.body).not_to include('data-controller="site--toc"')
      end
    end
  end

  describe "chrome: :full routes" do
    %w[/docs/getting-started /docs/theming /docs/philosophy
       /docs/components/button /docs/components/dialog
       /docs/components/dropdown_menu /docs/components/tabs
       /docs/components/checkbox /docs/components/input /docs/components/label
       /docs/components/select /docs/components/switch /docs/components/textarea
       /docs/components/alert /docs/components/avatar /docs/components/badge
       /docs/components/card /docs/components/separator
       /docs/components/drawer /docs/components/popover /docs/components/tooltip
       /docs/components/accordion /docs/components/toast
       /docs/components/toggle /docs/components/radio_group
       /docs/components/toggle_group /docs/components/slider
       /docs/components/combobox /docs/components/form
       /docs/components/command /docs/components/number_input
       /docs/components/sidebar /docs/components/date_picker
       /docs/components/input_otp /docs/components/file_upload /docs/components/context_menu
       /docs/components/rating_group /docs/components/hover_card
       /docs/components/tags_input /docs/components/collapsible
       /docs/components/splitter /docs/components/carousel
       /docs/components/navigation_menu /docs/components/color_picker].each do |path|
      it "GET #{path} returns 200 with sidebar AND TOC" do
        get path
        expect(response).to have_http_status(:ok)
        expect(response.body).to match(/aside[^>]*hidden lg:block/)
        expect(response.body).to include('data-controller="site--toc"')
      end
    end
  end

  describe "Combobox async search" do
    it "GET /docs/components/combobox/search returns an item fragment" do
      get "/docs/components/combobox/search", params: { q: "rails" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('data-wabi--combobox-target="item"')
      expect(response.body).to include("Ruby on Rails")
    end

    it "GET /docs/components/combobox/search with no match returns a No results fragment" do
      get "/docs/components/combobox/search", params: { q: "zzzznomatch" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("No results")
      expect(response.body).not_to include('data-wabi--combobox-target="item"')
    end
  end

  describe "SearchBox" do
    it "renders the search div in the header on non-bare routes" do
      get "/docs/components"
      expect(response.body).to include('id="search"')
      expect(response.body).to include('data-controller="site--search"')
    end

    it "does NOT render the SearchBox on bare routes" do
      get "/"
      expect(response.body).not_to include('data-controller="site--search"')
    end
  end
end
