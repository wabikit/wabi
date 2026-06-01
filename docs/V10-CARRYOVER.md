# v0.10 Carryover — closed 2026-06-01

Sprint 14 closed the toast group-coordination carryover that had been deferred
since v0.5. v0.10.0 tagged 2026-06-01. One breaking change (toast transform).

## Closed in v0.10

- **Toast group coordination** — Sonner-style stacking (`visible_count`/`gap`),
  expand-on-group-hover, group pause-on-hover, overflow-that-surfaces, and
  swipe-to-dismiss. Built as a custom two-controller coordinator
  (`wabi--toaster` + `wabi--toast` via Stimulus outlets) with a pure
  `computeStack` layout function — deliberately **not** the `@zag-js/toast`
  machine, whose create-and-render model looped against SSR + Turbo Stream in
  v0.5. The coordinator only reads the DOM and writes inline styles, so there is
  no feedback loop.

## Known limits documented in v0.10

- **No JS unit tests** for `computeStack` / the controllers (no JS runner in the
  project). `computeStack` is written as a pure function so a runner can be added
  later without rework; behavior is verified manually (see `SMOKE-TEST.md`).
- **Single-level stack only** — all toasts in one Toaster share one stack;
  there is no nested/grouped-by-type stacking.

## Carried over (still deferred)

- **Phlex 2.4 Ruby 4 warnings** — upstream.
