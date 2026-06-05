# frozen_string_literal: true

class ComponentsController < ApplicationController
  layout false

  # All 31 components (20 from v0.4 plus toggle + radio_group + toggle_group + slider + combobox + form + command from v0.6
  # plus skeleton + breadcrumb + pagination + progress).
  # Every name routes to a detail page.
  ALL = %w[
    button input textarea label card badge separator alert avatar
    checkbox switch select dialog drawer tooltip popover
    dropdown_menu toast tabs accordion toggle radio_group toggle_group
    slider combobox form command table skeleton breadcrumb pagination progress
    alert_dialog data_table number_input sidebar date_picker
  ].freeze

  FRAMEWORKS = [
    { value: "rails",   label: "Ruby on Rails" },
    { value: "django",  label: "Django" },
    { value: "phoenix", label: "Phoenix" },
    { value: "express", label: "Express" },
    { value: "fastapi", label: "FastAPI" },
    { value: "laravel", label: "Laravel" },
    { value: "spring",  label: "Spring" },
    { value: "flask",   label: "Flask" },
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

  def combobox_search
    q = params[:q].to_s.downcase
    matches = FRAMEWORKS.select { |f| f[:label].downcase.include?(q) }
    html = if matches.empty?
      %(<li class="px-2 py-1.5 text-sm text-muted-foreground">No results</li>)
    else
      matches.map { |f| ::Components::UI::ComboboxItem.new(value: f[:value]).call { f[:label] } }.join
    end
    render html: html.html_safe, layout: false
  end
end
