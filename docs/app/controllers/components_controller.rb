# frozen_string_literal: true

class ComponentsController < ApplicationController
  layout false

  # All 27 components (20 from v0.4 plus toggle + radio_group + toggle_group + slider + combobox + form + command from v0.6).
  # Every name routes to a detail page.
  ALL = %w[
    button input textarea label card badge separator alert avatar
    checkbox switch select dialog drawer tooltip popover
    dropdown_menu toast tabs accordion toggle radio_group toggle_group
    slider combobox form command
  ].freeze

  def index
    render Views::Pages::Components::Index.new
  end

  def show
    name = params[:name]
    raise ActionController::RoutingError, "Unknown component: #{name}" unless ALL.include?(name)

    klass = "Views::Pages::Components::#{name.camelize}".constantize
    render klass.new
  end
end
