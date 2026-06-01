# v0.12 Carryover — closed 2026-06-01

v0.12.0 filled five common shadcn gaps (→ 33 components). No breaking changes,
no new deferrals.

## Closed in v0.12

- **Skeleton** — pulsing loading placeholder, sized via utility classes.
- **Breadcrumb** — 7 composable, static parts (chevron SVGs inlined).
- **Pagination** — 7 composable, link-based, server-driven parts;
  `PaginationLink(active:)` toggles outline-vs-ghost + `aria-current="page"`.
- **Progress** — value-driven `role="progressbar"` bar (`value:`/`max:`), no JS.
- **AlertDialog** — mirror of Dialog on the `@zag-js/dialog` machine, but
  `role="alertdialog"`, **does not dismiss on click-outside**
  (`closeOnInteractOutside: false`; Escape and Cancel/Action still close), and
  puts initial focus on the Cancel button. Reuses the shared portal helpers.

## Notes

- The 4 static components were verified by render specs + live page render; the
  interactive AlertDialog behavior (no outside-dismiss, Escape, focus Cancel)
  was verified manually in the browser (no JS test runner).

## Carried over (still deferred)

- **Phlex 2.4 Ruby 4 warnings** — upstream. (The only open item across the whole
  project — every numbered v0.1–v0.9 carryover is now closed.)
