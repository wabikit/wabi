# v0.13 Carryover — closed 2026-06-01

v0.13.0 added the server-driven DataTable (→ 34 components). No breaking changes,
no new deferrals.

## Closed in v0.13

- **DataTable** — composes `Table` + `Pagination`:
  - `DataTableColumnHeader` — sortable header link + asc/desc/neutral indicator,
    static. The Rails controller orders the query and computes the toggle href;
    Turbo re-navigates. No client-side data.
  - `DataTableCheckbox` — native, theme-styled checkbox (`accent-primary`), NOT
    the Zag Checkbox, so a page of N rows doesn't spawn N machines.
  - `wabi--data-table` controller — select-all + indeterminate, per-row
    `data-state="selected"`, and a `wabi--data-table:change` event carrying the
    selected values for bulk actions.

## Known limits documented in v0.13

- **No built-in filtering / column-visibility toggle** — filtering is an app
  form; both were deliberately out of scope (not deferrals).
- **Sort/page hrefs are app-computed** — the component is presentational; the
  docs page shows the full `params`-driven pattern.

## Carried over (still deferred)

- **Phlex 2.4 Ruby 4 warnings** — upstream (still the only open item).
