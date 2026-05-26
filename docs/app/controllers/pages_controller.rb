# frozen_string_literal: true

class PagesController < ApplicationController
  layout false

  def home
    render Views::Pages::Home.new
  end

  def preview
    render Views::Pages::Preview.new
  end

  def themes
    render Views::Pages::Themes.new
  end

  def getting_started
    render Views::Pages::Docs::GettingStarted.new
  end

  def philosophy
    render Views::Pages::Docs::Philosophy.new
  end

  def theming
    render Views::Pages::Docs::Theming.new
  end
end
