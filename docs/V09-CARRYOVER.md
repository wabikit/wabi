# v0.9 Carryover — closed 2026-05-31

Sprint 13 closed the low-risk v0.9 carryovers and fully fixed the vertical
Slider (surfaced during user testing). v0.9.0 tagged 2026-05-31. See
[CHANGELOG.md](../gem/CHANGELOG.md). One breaking change (Slider marks API).

## Closed in v0.9

- **`wabi:update` three-way merge** via `git merge-file` (base content stored in
  the lockfile as `{hash, content}`; legacy lockfiles + missing git fall back to
  the prompt; a guard prevents writing a blank file on git error).
- **Combobox async error state** (`ComboboxError` slot).
- **Vertical Slider** — now renders + fills + aligns marks (control fills height,
  thumb cross-axis centering, range `w-full`, marks inside `SliderControl`).

## Known limits documented in v0.9

- **`wabi:update` three-way merge requires git on PATH** and a lockfile written
  by v0.9+ `wabi:add`/`wabi:update` (which store base content). Pre-v0.9
  lockfiles use the y/n/d/q prompt until the next successful update reseeds
  `{hash, content}`. The merge uses standard `<<<<<<<`/`=======`/`>>>>>>>`
  markers; conflicts must be resolved by hand.
- **Slider `marks:` is on `SliderControl`** (not `Slider`) as of v0.9, and
  `SliderControl` also takes `orientation:` for the marks layout. The marks are
  absolutely positioned relative to the control; Zag spreads `position:relative`
  on the markerGroup target, so the component wraps it in an outer absolute div.

## Carried over (still deferred to v0.10+)

- **Toast `@zag-js/toast` group machine** — high-risk; failed twice (v0.5, then
  deferred through v0.7/v0.8/v0.9). Pair with cross-toast coordination.
- **Phlex 2.4 Ruby 4 warnings** — upstream.
