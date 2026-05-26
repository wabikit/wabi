# frozen_string_literal: true

class PagesController < ApplicationController
  layout false

  def home
    render Views::Pages::Home.new
  end

  def themes
    render Views::Pages::Themes.new
  end
end
