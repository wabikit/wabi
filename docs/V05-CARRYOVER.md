# v0.5 Carryover — closed 2026-05-27

All four blocking items planned for v0.5 are resolved. v0.5.0 was tagged
on 2026-05-27. See [CHANGELOG.md](../CHANGELOG.md) for the full release
entry.

The v0.1/v0.2 carryovers in `docs/V01-CARRYOVER.md` are now superseded:

- **#3 Real portal pattern**: closed by Task 4. See
  `[[zag-js-pattern]]` entry 11 for the capture-before-move +
  `WabiPortalRegistry` pattern.
- **#6 `wabi:update` generator**: closed by Task 2 (deferred from
  v0.1 #6).
- **Docs `+esm` footnote backfill**: closed by Task 1.

## Deferred to v0.6

- **Toast `@zag-js/toast` group machine** — v0.5 attempt caused a runtime infinite loop in our Phlex+Stimulus+Turbo setup; reverted to v0.4 vanilla setTimeout. Plan to retry with a different shape (separate Stimulus controllers per toast OR custom JS group coordinator) in v0.6.
- Toast Sonner-style enter/exit animations. Currently toasts appear/dismiss
  with no transition. Plan to add `data-state="open|closed"` driven Tailwind
  variants on the Toast component (same pattern as Drawer slide-in) when
  the toast group machine returns in v0.6 — both changes land together
  since the animation hooks into machine state.
- **Forms wave**: RadioGroup, Toggle, ToggleGroup, Slider, Combobox,
  Command, Form. Largest wave; RadioGroup leverages DropdownMenu radio
  primitives.
- **Nav wave**: Sheet, ContextMenu, Pagination, NavigationMenu. Sheet
  is a Drawer rename/extension; ContextMenu reuses DropdownMenu.
- **Data wave**: Calendar, DatePicker, DataTable. Most ambitious;
  diverges most from current Zag wiring.
- **`wabi:update` three-way merge**. Current v0.5 prompts on conflict.
  A future enhancement could attempt an automatic merge using the
  original installed content + local edits + new payload (git-style).
- **DropdownMenu multi-level nesting** (sub-inside-sub). v0.5 still only
  supports single-level submenus.
- **Phlex 2.4 Ruby 4 warnings**. Still waiting on upstream.
- **Overlay portal controller boilerplate**. The 5 overlay controllers
  share substantial `attachToBody`/`restoreFromBody`/captured-refs
  boilerplate. A shared mixin / base class could deduplicate this if a
  6th overlay arrives.
- **Vestigial `wabi--<name>-target="portal"` wrappers in
  `*_content.rb`**. Stay in place for v0.5 to keep DOM stable when
  `portal: false`; clean up in v0.6.

## Known limits documented in v0.5

- **Turbo morphing flash**: replacing a controller-hosting element via
  Turbo Frame/Stream causes a one-frame snap of the portaled content
  back to its original position before reconnect repaints. Mitigation:
  wrap the trigger in `data-turbo-permanent`. Apps without morph/stream
  near overlays never see this.
- **`WabiPortalRegistry.applyInert` walks `document.body.childNodes`**
  on every open/close — fine for the typical page, potentially slow
  for pages with hundreds of top-level elements. Revisit if perf
  complaints surface.
- **Toast swipe direction is per-Toaster**, not per-toast. v0.5 ships
  one swipe direction per Toaster instance (default `"right"`).
- **`window.wabiToaster` is a global**; with multiple Toasters on the
  same page, the last-connected one wins. Future v0.6 work may move to
  `window.wabiToasters[id]` keyed by id.
