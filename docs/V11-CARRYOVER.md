# v0.11 Carryover — closed 2026-06-01

v0.11.0 added the Table component. One breaking change (Toast transform, carried
from the v0.10 cut's notes); no new deferrals.

## Closed in v0.11

- **Table component** (shadcn parity) — 8 static composable primitives
  (`Table`/`TableHeader`/`TableBody`/`TableFooter`/`TableRow`/`TableHead`/
  `TableCell`/`TableCaption`), Card pattern, no JS. `Table` wraps `<table>` in a
  `relative w-full overflow-auto` container.
- **ClassMerge `text-align` fix** (surfaced by `TableHead`, which needs both
  `text-left` and `text-muted-foreground`): the six text-align utilities
  (`left`/`center`/`right`/`justify`/`start`/`end`) now dedup in their own
  `text:align` bucket instead of colliding with `text-{color}`. Closes a
  long-standing v0.1 ClassMerge edge case.

## Known limits documented in v0.11

- **No interactivity** — Table is presentational only; sorting/pagination stay
  server-driven (params + Turbo). A `DataTable` with sortable headers / row
  selection remains a possible future component, not a deferral.

## Carried over (still deferred)

- **Phlex 2.4 Ruby 4 warnings** — upstream.
