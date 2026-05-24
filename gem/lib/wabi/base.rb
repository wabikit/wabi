# frozen_string_literal: true

require "phlex"
require_relative "variants"

module Wabi
  # Base class for all Wabi UI components.
  # Subclasses inherit from Phlex::HTML and get the Variants DSL.
  class Base < Phlex::HTML
    extend Wabi::Variants
  end
end
