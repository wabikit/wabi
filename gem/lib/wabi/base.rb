# frozen_string_literal: true

require "phlex"
require_relative "variants"
require_relative "class_merge"

module Wabi
  class Base < Phlex::HTML
    extend Wabi::Variants

    private

    def merge_class(*classes)
      Wabi::ClassMerge.call(*classes)
    end
  end
end
