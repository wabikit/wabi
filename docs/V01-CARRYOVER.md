# v0.1 Carryover — closed 2026-05-26

This doc tracked work that had to land before tagging v0.1. **All blocking
items are resolved. v0.1.0 was tagged on 2026-05-26.** See
[CHANGELOG.md](../CHANGELOG.md) at the repo root for the release entry.

The Sprint 0/1 carryovers (numbered #1-#6 in
`memory/project_v01_carryover.md`) are all resolved separately.

---

## Resolved during the Sprint 4 cleanup pass (2026-05-26)

- **ClassMerge — atom utilities (`flex` vs `flex-col`, `border` vs
  `border-input`, etc.)** — atom set added in Sprint 3, expanded color/size
  family logic in Sprint 4 cleanup. `border`/`ring`/`text`/`outline`/`divide`
  now distinguish size from color; `ring-offset` is its own family. Both
  width and color survive dedup in the common cases.
- **ClassMerge — axis-aware grouping (`-translate-x` vs `-translate-y`,
  `border-l` vs `border-r`)** — handled via `AXIS_FAMILIES` + `AXIS_SUFFIXES`.
- **`wabi_toast` Turbo Stream action helper** — `turbo_stream.wabi_toast(title:
  "...", appearance: :success)` shorthand appended to `Turbo::Streams::TagBuilder`
  when Turbo is loaded. Lives in `gem/lib/wabi/turbo_stream_extensions.rb`.
- **DropdownMenu — CheckboxItem + RadioGroup + RadioItem** — three
  sub-components added with `role="menuitemcheckbox"` / `role="menuitemradio"`,
  state managed in `data-wabi-checked` and toggled by the parent
  `wabi--dropdown-menu` controller via `onSelect`.
- **Overlay enter/exit animations (Dialog, Drawer, Tooltip, Popover,
  DropdownMenu, Select)** — visibility moved off the `hidden` attribute
  onto `data-state` + Tailwind `data-[state=open|closed]:` variants for
  `opacity` / `translate` / `pointer-events`. The controller force-clears
  `hidden` after Zag's spreadProps so display:none doesn't cut the
  transition off mid-fade. Drawer slides per side; Dialog and Tooltip/
  Popover/DropdownMenu/Select fade.

---

## Resolved during v0.1 polish (2026-05-26, post-Sprint-5)

1. **Overlay `inert` toggling** (`d778d95`). All six overlays carry
   `inert` on closed content; the toggle lives in each controller's
   `onOpenChange` callback (synchronous inside Zag's state transition,
   so it lands before the entry-phase `setInitialFocus` action — the
   earlier Sprint 4 attempt put it in `render()` and lost the race).
   Phlex sources emit `inert` initially; controller flips it on every
   open/close.

2. **DropdownMenu nested submenus** (`6720445`). Three new components
   (`DropdownMenuSub` / `DropdownMenuSubTrigger` / `DropdownMenuSubContent`)
   + a controller rewrite that owns the parent menu machine plus one Zag
   menu machine per `sub` boundary. setChild / setParent take MenuService
   (verified against `@zag-js/menu@1.41` type defs), called after start()
   once both services exist. Parent and sub machines share one Stimulus
   controller because nested same-id controllers would hide each other's
   targets via Stimulus scoping. v0.1 limit: single-level nesting.

3. **Submenu CheckboxItem / RadioItem** (also `6720445`). Free for
   nothing: the route-by-closest-sub-ancestor strategy in the controller
   picks the right machine's API for option items, so existing
   `DropdownMenuCheckboxItem` / `DropdownMenuRadioItem` work inside a
   `SubContent` with no new components.

5. **Phlex `<template>` ↔ layout capture interaction** (`ebcc495`).
   Investigated and found NOT to reproduce after the Sprint 4
   `raw safe(yield_content(&block))` cleanup. Three repros (minimal
   Phlex view; fake layout with yield_content + sibling-after-capture;
   full-fat Toast inside `<template>` blocks) all rendered cleanly with
   surrounding content intact. The docs Toast demo is back on the
   cleaner `<template>` + cloneNode pattern.

6. **`bin/dev` cold-start polish** (`8bef116`). `bin/dev` pre-flights
   `docs/tmp/pids/server.pid` — if the recorded pid isn't running, the
   stale file is removed; if it IS running, `bin/dev` exits loudly
   rather than stomping the active server.

---

## Deferred to v0.2

These are items that did not block v0.1 and are either architectural
follow-ups or wait-for-upstream:

1. **Toast — `@zag-js/toast` group machine.** Current v0.1 implementation
   is a vanilla `setTimeout`-based per-toast controller; no cross-toast
   coordination. Migrating gives `max` (stack limit), `gap`/`offset`
   spacing, pause-on-group-hover. Architecture: Toaster element runs the
   group machine; each Toast's `wabi--toast-target="connectedTarget"` is
   queried on `targetConnected` and registered via
   `service.start({ ...config, id })`.

2. **Phlex 2.4.1 Ruby 4.0.5 warnings.** Phlex emits `assigned but unused
   variable - stack` at load time on Ruby 4. Not blocking; revisit if
   Phlex 2.5+ doesn't fix upstream. Workaround: `config.warnings = false`
   in `spec_helper`, but we keep it on for now to catch genuine issues.

3. **Real portal pattern.** Currently disabled — `position: fixed` + high
   z-index escapes normal flow for ~99% of layouts. Edge case: a
   transformed ancestor traps fixed positioning. v0.2 path: capture
   native DOM refs to nested elements BEFORE appending to body, and call
   `spreadProps` / set visibility state on those captured refs instead of
   through Stimulus targets (which lose tracking when the subtree moves
   out of scope).

4. **ClassMerge — full `tailwind-merge`-equivalent dedup.** Current
   heuristics cover the common conflicts. Edge cases that still collide:
   - `bg-{utility}` non-color modifiers like `bg-cover`/`bg-contain`/
     `bg-no-repeat` collapse under the generic `bg` family.
   - `text-{font-style}` like `text-italic` (rare in TW4) not handled.
   - `SIZE_TOKENS` is curated by hand; new keywords (e.g. `text-2xs`)
     would need to be added.

5. **DropdownMenu multi-level nesting.** v0.1 supports single-level
   submenus only. Sub-inside-a-sub would need another controller pass
   since a child sub's items aren't routed beyond the parent controller's
   reach. Realistic use cases for 2+ levels are rare in well-designed
   menus.

6. **`wabi:update` generator** (diff-aware, fetches latest tokens, runs
   `tailwindcss:build`). `wabi:install --force` is the v0.1 minimum; a
   proper update flow with confirmation prompts and conflict detection
   is the v0.2 path.

7. **Component theming with multiple palettes.** `wabi:install` ships
   one default theme; the architecture supports more via
   `data-theme="..."` on `<html>` and CSS variable swaps. Sprint 6
   (themes + docs polish) is the planned home for the theme picker UI
   and the documented theme-extension flow.

8. **Portal-driven overlay positioning for layouts with transformed
   ancestors** — see #3 above.
