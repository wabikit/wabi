# frozen_string_literal: true

class ComponentsController < ApplicationController
  layout false

  # All 20 v0.4 components. The /docs/components index lists all of them;
  # /docs/components/:name routes to a detailed page for every entry in
  # DETAILED — which now matches ALL exactly, so B5 will drop the gate.
  ALL = %w[
    button input textarea label card badge separator alert avatar
    checkbox switch select dialog drawer tooltip popover
    dropdown_menu toast tabs accordion
  ].freeze

  DETAILED = %w[button dropdown_menu dialog tabs
                checkbox input label select switch textarea
                alert avatar badge card separator
                drawer popover tooltip
                accordion toast].freeze

  def index
    render Views::Pages::Components::Index.new
  end

  def show
    name = params[:name]
    raise ActionController::RoutingError, "Unknown component: #{name}" unless ALL.include?(name)
    raise ActionController::RoutingError, "Detailed docs not yet shipped for: #{name}" unless DETAILED.include?(name)

    klass = "Views::Pages::Components::#{name.camelize}".constantize
    render klass.new
  end
end
