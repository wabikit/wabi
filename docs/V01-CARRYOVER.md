# v0.1 Carryover

Consolidated list of items deferred past Sprint 4 — to address before tagging
v0.1 OR explicitly punt to v0.2. Updated 2026-05-26 at the end of the Sprint
4 cleanup pass.

The Sprint 0/1 carryovers (numbered #1-#6 in `memory/project_v01_carryover.md`)
are all resolved. This document tracks what remains.

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

## Still open — should land before v0.1 ships

1. **Overlay `inert` toggling for tab-order + screen-reader correctness.**
   The closed overlay content is currently `opacity: 0` + `pointer-events:
   none`, but still tabbable + announced by screen readers. Initial attempt
   in the Sprint 4 cleanup pass set `inert` on close — it raced with Zag's
   focus-trap initialization on open and broke the dialog's interactivity.
   Need to toggle `inert` on the controller AFTER Zag's `setInitialFocus`
   action completes (or use a `closed`-state phase signal Zag exposes via
   subscribe). Investigation needed: inspect Zag dialog machine state
   ordering, possibly hook into `onOpenChange` instead of subscribe.

2. **DropdownMenu — Submenu.** Nested menu (`triggerItem` part in Zag's
   anatomy). Requires a child `wabi--dropdown-menu` controller whose machine
   is connected to the parent's via `triggerItem` ↔ child's `trigger`. Zag's
   `getTriggerItemProps` merges parent's `getItemProps` with child's
   `getTriggerProps` so the submenu opens on hover/arrow-right.

3. **DropdownMenu — Submenu CheckboxItem / RadioItem**, if needed. Probably
   inherits the same option-item machinery as the top-level menu.

4. **Toast — integrate `@zag-js/toast` group machine + per-toast machine.**
   The v0.1 implementation is a vanilla `setTimeout`-based controller per
   toast, no cross-toast coordination. Migrating gives us `max` (stack
   limit), `gap`/`offset` spacing, and pause-on-group-hover. Architecture:
   the Toaster element runs the group machine; each Toast's
   `wabi--toast-target="connectedTarget"` is queried on `targetConnected` and
   registered with the group via `service.start({ ...config, id })`.

5. **Phlex `<template>` ↔ layout capture interaction.** During Sprint 4 Toast
   debugging, putting `<template>...</template>` blocks inside a Phlex view
   that's rendered through `Components::Site::Layout`'s `yield_content`
   appeared to interact badly with the captured buffer — the surrounding
   content disappeared. Root-causing this would unlock the cleaner
   `<template>` + `cloneNode` Stimulus pattern (currently we side-step with
   Stimulus String values + `insertAdjacentHTML`). Repro: simple Phlex view
   with `template do ... end` blocks inside the main body, see if the rest
   of the body renders.

6. ~~**`bin/dev` cold-start polish**~~ — **resolved during v0.1 polish.**
   `bin/dev` now pre-flights `docs/tmp/pids/server.pid`: if the recorded
   pid is no longer alive, it removes the stale file; if it points to a
   running process, it exits loudly so we don't stomp an active server.

7. **Phlex 2.4.1 emits Ruby 4.0.5 warnings (`assigned but unused variable -
   stack`) at load time.** Not blocking; revisit if Phlex 2.5+ doesn't fix
   upstream. Workaround: `config.warnings = false` in spec_helper, but we
   keep it on for now to catch genuine issues.

---

## Likely deferrals to v0.2

1. **Real portal pattern.** Currently disabled — `position: fixed` + high
   z-index escapes normal flow for ~99% of layouts. Edge case: a transformed
   ancestor traps fixed positioning. v0.2 path: capture native DOM refs to
   nested elements BEFORE appending to body, and call `spreadProps` / set
   visibility state on those captured refs instead of through Stimulus
   targets (which lose tracking when the subtree moves out of scope).

2. **ClassMerge — full `tailwind-merge`-equivalent dedup.** Current
   heuristics cover the common conflicts (atoms, axes, width-vs-color in a
   handful of families). Edge cases that still collide:
   - `bg-{utility}` non-color modifiers like `bg-cover`/`bg-contain`/
     `bg-no-repeat` collapse under the generic `bg` family.
   - `text-{font-style}` like `text-italic` (rare in Tailwind 4 — usually
     `italic` atom) — not currently handled.
   - The font-size keyword set (`SIZE_TOKENS`) is curated by hand; new
     keywords like `text-2xs` if they ship would need to be added.

3. **Portal-driven overlay positioning for layouts with transformed
   ancestors** — see #1 above.

4. **Wabi `wabi:update` generator** (diff-aware, fetches latest tokens,
   runs `tailwindcss:build`). `wabi:install --force` is the v0.1 minimum
   but a proper update flow with confirmation prompts and conflict
   detection is missed.

5. **Component theming with multiple palettes.** `wabi:install` ships one
   default theme; the architecture supports more via `data-theme="..."`
   on `<html>` and CSS variable swaps. Sprint 6 is supposed to ship a
   theme picker UI and a documented theme-extension flow.

---

## Sprint 5 closed (2026-05-26)

Tabs + Accordion shipped (`d7822d1`, `2a5f108`); CI verifies all 20 v0.1
dist artifacts (`99edec4`). Registry suite 115/115, gem 64/64. Sprint 5
deviated from its plan in one place worth keeping in mind: Accordion
content animation uses a CSS `grid grid-rows-[0fr] →
data-[state=open]:grid-rows-[1fr] transition-[grid-template-rows]`
trick instead of the plan's `tailwindcss-animate` keyframes (which we
don't have in TW4). The inner wrapper is `overflow-hidden`; controller
forces `el.hidden = false` after Zag's spreadProps so the transition
runs — same pattern Sprint 4 overlay cleanup adopted.

With the **v0.1 component-coverage milestone reached (20 components)**,
the remaining open items above are the v0.1 polish punch-list. Sprint 6
(themes + docs polish) plan is the next natural step.
