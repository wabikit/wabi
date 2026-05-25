# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    render Views::Pages::Home.new
  end
end
