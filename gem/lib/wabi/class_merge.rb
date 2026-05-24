# frozen_string_literal: true

module Wabi
  # Minimal Tailwind class deduplication. Later tokens win for the same group prefix.
  # Group prefix = first hyphen-separated segment (e.g. "h-8" → group "h", "bg-red-500" → group "bg").
  # NOTE: This is intentionally minimal for Sprint 0. Full Tailwind conflict resolution
  # (e.g. understanding that p-4 conflicts with px-4 + py-4) is post-v0.1.
  module ClassMerge
    module_function

    def call(*inputs)
      tokens = inputs.compact.flat_map { |s| s.to_s.split(/\s+/) }.reject(&:empty?)
      seen = {}
      tokens.each do |token|
        group = token.split("-").first
        seen[group] = token
      end
      seen.values.join(" ")
    end
  end
end
