# v0.8 Carryover — closed 2026-05-31

All four items from the Sprint 12 plan landed. v0.8.0 was tagged on 2026-05-31.
See [CHANGELOG.md](../gem/CHANGELOG.md) for the full release entry. No breaking
changes this release.

## Closed in v0.8

- Combobox async items (HTML-fragment fetch + DOM-collection rebuild).
- Slider marks/ticks (`marks:` kwarg).
- `motion-reduce:transition-none` on Toast + animated overlays (a11y).
- Overlay controller refactor: shared `_shared/overlay_portal.js`; DropdownMenu
  ancestor-lookup dedup; PortalRegistry disconnect ordering; sub-index cleanup.

## Known limits documented in v0.8

- **Combobox async requires a server endpoint** returning an HTML fragment of
  `ComboboxItem`s. The controller rebuilds the Zag collection at runtime via
  `machine.updateProps({ collection })` (verified against `@zag-js/vanilla@1.41`;
  there is no `setCollection` API). The optional `ComboboxLoading` slot is
  tracked via a cached element reference (`_loadingEl`), NOT a Stimulus target —
  because the content is portaled outside the controller's subtree, so Stimulus
  never registers in-content targets after the move. `replaceItems` preserves
  and re-prepends that slot across the `innerHTML` swap.
- **Combobox async error UX is minimal:** on fetch failure the prior results are
  kept and a `console.warn` fires; there is no rich inline error message (the
  `aria-live` attribute on `ComboboxLoading` covers discreet announcement).
  Richer error UX is deferred.
- **Slider mark labels assume horizontal orientation** (`mt-2` offset). Vertical
  sliders need a horizontal (`ml-*`) label offset — deferred follow-up.
- **`_shared/overlay_portal.js`** moves `positionerEl || contentEl` (+ backdrop
  for Dialog). All five overlays that adopted it move only their positioner;
  the content/backdrop fallbacks exist for Dialog/Drawer shapes.

## Carried over (still deferred to v0.9+)

- **Toast `@zag-js/toast` group machine retry** — failed twice (v0.5, deferred
  through v0.7/v0.8); pair with cross-toast coordination.
- **`wabi:update` three-way merge** — auto-merge original + local + new payload
  instead of prompting on conflict.
- **Phlex 2.4 Ruby 4 warnings** — upstream.
- **Combobox async richer error UX** + **vertical Slider mark labels** (above).
