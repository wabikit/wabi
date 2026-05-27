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
       /docs/components/drawer /docs/components/popover /docs/components/tooltip].each do |path|
      it "GET #{path} returns 200 with sidebar AND TOC" do
        get path
        expect(response).to have_http_status(:ok)
        expect(response.body).to match(/aside[^>]*hidden lg:block/)
        expect(response.body).to include('data-controller="site--toc"')
      end
    end
  end
end
