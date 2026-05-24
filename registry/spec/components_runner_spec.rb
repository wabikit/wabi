# frozen_string_literal: true

# Loads every registry/components/<name>/spec.rb so CI runs them together.
Dir[File.expand_path("../components/*/spec.rb", __dir__)].sort.each do |spec_path|
  component_dir = File.dirname(spec_path)
  $LOAD_PATH.unshift(component_dir) unless $LOAD_PATH.include?(component_dir)
  load spec_path
end
