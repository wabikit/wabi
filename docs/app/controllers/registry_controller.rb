# frozen_string_literal: true

class RegistryController < ApplicationController
  REGISTRY_DIST = Rails.root.join("..", "registry", "dist", "r").realpath

  def show
    name = params[:name]
    raise ActionController::BadRequest, "Invalid component name" unless name =~ /\A[a-z][a-z0-9_]*\z/

    path = REGISTRY_DIST.join("#{name}.json")
    if path.exist? && path.to_s.start_with?(REGISTRY_DIST.to_s)
      send_file path, type: "application/json", disposition: "inline"
    else
      head :not_found
    end
  end
end
