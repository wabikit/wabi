# v0.7 Carryover — closed 2026-05-30

All 10 items from the Sprint 11 plan landed. v0.7.0 was tagged on
2026-05-30. See [CHANGELOG.md](../gem/CHANGELOG.md) for the full release
entry.

## Closed in v0.7

- ComboboxItemIndicator wired through `getItemIndicatorProps`.
- Combobox per-item `disabled` end-to-end (Tailwind `data-[disabled]:*` +
  Zag `isItemDisabled` collection both honor it).
- Portal-using overlays no longer ship the vestigial portal-target wrapper
  (Dialog, Drawer, Command dialog; the other overlays were already clean).
- `WabiPortalRegistry` caches the body-siblings list across open/close cycles.
- Slider range hidden inputs use Rails-native `name[min]` / `name[max]`.
  **BREAKING.**
- Command palette item selection closes the dialog (document-level event
  delegation with id linkage).
- Command auto-opens the combobox when the dialog opens.
- Toast Sonner-style slide + fade animations on enter / exit.
- `window.wabiToasters[id]` keyed registry; `turbo_stream.wabi_toast` accepts
  `toaster_id:`.
- DropdownMenu N-level submenu nesting.

## Known limits documented in v0.7

- **Command bridge id linkage** depends on the root rendering
  `data-controller="wabi--command wabi--dialog"` (command-first order). The
  bridge stamps the dialog content with `data-wabi--command-id` at connect,
  which runs BEFORE `wabi--dialog#attachToBody` portals it — because Stimulus
  connects controllers left-to-right and `wabi--command` is listed first. If a
  future change swaps that order, the linkage breaks silently. The command-id
  is read/written via `getAttribute`/`setAttribute` (NOT `dataset`) because the
  double-dash attribute `data-wabi--command-id` maps to the dataset key
  `wabi-CommandId`, not `wabiCommandId`.
- **Command combobox collection** is built from the rendered DOM items when no
  `items` value is supplied (the palette authors items as static HTML). This
  DOM-fallback path reads `data-wabi-disabled` (emitted by `CommandItem`); it is
  never reached by a standalone Combobox, which always passes a JS `items` array.
- **Toast enter animation** uses a double-`requestAnimationFrame` flip in the
  controller's `connect()` (snap to `closed`, then `open` next frame). SSR
  renders `data-state="open"` as the no-JS fallback. A 350ms `setTimeout`
  safety force-removes the toast on dismiss if `transitionend` never fires.
- **DropdownMenu N-level submenus** require each sub's `data-wabi-sub-id` to
  remain unique across the page; `SecureRandom.uuid` provides that. Dynamically
  inserted subs (after `connect()`) are not wired — same limitation as v0.6.

## Carried over from earlier sprints (still deferred to v0.8)

- **Combobox async items** — server-side fetching via Turbo Frame / callback
  URL / fetch-on-input.
- **Toast `@zag-js/toast` group machine retry** — pair with cross-toast
  coordination (max visible, per-toast swipe direction).
- **`wabi:update` three-way merge** — auto-merge using original + local + new
  payload instead of prompting on conflict.
- **Slider marks/ticks** at specific track positions.
- **Overlay controller boilerplate refactor** — the portal-using overlays share
  attach/restore + ref-capture boilerplate; the DropdownMenu ancestor-lookup
  (`parentElement.closest('[...-target="sub"]')` + fallback) is duplicated
  verbatim between `connect()` and `render()`. Extract a shared mixin / helper
  when a 7th overlay or another nesting change arrives.
- **`motion-reduce:transition-none`** on Toast (and the animated overlays) so
  reduced-motion users skip the slide/fade. Today the 350ms dismiss fallback
  keeps them unbroken, but the transition still nominally runs.
- **`WabiPortalRegistry` unregister/restoreFromBody ordering** — `disconnect()`
  calls `unregister` (which rebuilds the sibling cache) before `restoreFromBody`
  moves the portal nodes out, so the cache briefly lists about-to-move nodes.
  Harmless in synchronous JS today; swap the order for cleanliness.
- **`data-wabi-sub-index` cleanup** — DropdownMenu stamps it on connect but
  doesn't delete it on disconnect (re-stamped on reconnect, so benign).
- **Phlex 2.4 Ruby 4 warnings** — still waiting on upstream.
