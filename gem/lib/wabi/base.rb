# frozen_string_literal: true

require "phlex"

module Wabi
  # Base class for all Wabi UI components.
  # Subclasses inherit from Phlex::HTML and gain variant/class-merge helpers
  # in later tasks (Wabi::Variants, Wabi::ClassMerge).
  class Base < Phlex::HTML
  end
end
