# frozen_string_literal: true

class ComponentsController < ApplicationController
  layout false

  # All 20 v0.2 components. The /docs/components index lists all of them;
  # /docs/components/:name routes to a detailed page only for the entries
  # in DETAILED. Other names 404 with a helpful message until v0.4 fills
  # in the rest. (B5 drops the gate once all 16 detail pages ship.)
  ALL = %w[
    button input textarea label card badge separator alert avatar
    checkbox switch select dialog drawer tooltip popover
    dropdown_menu toast tabs accordion
  ].freeze

  DETAILED = %w[button dropdown_menu dialog tabs
                checkbox input label select switch textarea].freeze

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
