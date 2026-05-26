# frozen_string_literal: true

require "set"

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
      "#{prefix}#{utility_group(utility)}"
    end

    # Single-word "atom" utilities that name a CSS property whose compound
    # siblings (e.g. `flex` vs `flex-col`, `border` vs `border-input`) target
    # an entirely different property and must NOT share a dedup bucket. Without
    # this distinction, `flex flex-col` collapses to just `flex-col` -- the
    # display:flex rule is lost and the children don't lay out as a flex row.
    ATOM_UTILITIES = %w[
      flex grid block inline hidden visible
      border ring rounded outline
      transition truncate
      absolute relative fixed static sticky
    ].to_set.freeze

    # Directional / axial suffix segments that distinguish utilities in the
    # same family (e.g. `-translate-x-1/2` vs `-translate-y-1/2` are different
    # axes, `border-l` vs `border-r` are different sides). When the first
    # segment after the family root matches one of these, keep the family root
    # PLUS the direction segment as the group key.
    AXIS_FAMILIES = %w[translate -translate scale skew rotate space border].to_set.freeze
    AXIS_SUFFIXES = %w[x y z t b l r s e].to_set.freeze

    def utility_group(utility)
      return "atom:#{utility}" if ATOM_UTILITIES.include?(utility)

      segments = utility.split("-").reject(&:empty?)
      head = utility.start_with?("-") ? "-#{segments.first}" : segments.first
      tail = utility.start_with?("-") ? segments[1] : segments[1]

      return "#{head}-#{tail}" if AXIS_FAMILIES.include?(head) && AXIS_SUFFIXES.include?(tail)

      head
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
