# frozen_string_literal: true

module Wabi
  # Minimal Tailwind class deduplication. Later tokens win for the same group key.
  #
  # The group key is variant-aware: any variants stacked in front of a utility
  # (e.g. "focus-visible:", "data-[state=checked]:", "md:dark:") become part of
  # the key, so variant-scoped utilities never collide with their plain
  # counterparts. Inside a given variant scope, the key is the utility's first
  # hyphen-separated segment ("h-4" → "h", "bg-red-500" → "bg").
  #
  # NOTE: Still intentionally minimal for v0.1 — utilities that share a prefix
  # but represent different CSS properties (e.g. `ring-2` width vs `ring-ring`
  # color, or `border` width vs `border-primary` color) collide and the later
  # one wins. Full Tailwind conflict resolution (à la tailwind-merge) is
  # post-v0.1.
  module ClassMerge
    module_function

    def call(*inputs)
      tokens = inputs.compact.flat_map { |s| s.to_s.split(/\s+/) }.reject(&:empty?)
      seen = {}
      tokens.each do |token|
        seen[group_key(token)] = token
      end
      seen.values.join(" ")
    end

    def group_key(token)
      idx = last_colon_outside_brackets(token)
      if idx
        prefix  = token[0..idx]
        utility = token[(idx + 1)..]
      else
        prefix  = ""
        utility = token
      end
      "#{prefix}#{utility.split("-").first}"
    end

    # The last `:` that lives outside any `[...]` block. Arbitrary-value variants
    # like `data-[state=checked]:` may contain `:` inside the brackets, which
    # must not be treated as the variant→utility separator.
    def last_colon_outside_brackets(token)
      depth = 0
      idx   = nil
      token.each_char.with_index do |c, i|
        case c
        when "[" then depth += 1
        when "]" then depth -= 1
        when ":" then idx = i if depth.zero?
        end
      end
      idx
    end
  end
end
