# Changelog

All notable changes to Wabi land here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-05-26

First milestone release. 20 components, accessible, themable, no Zag.js
0.x quirks left, no public gem / GitHub repo yet.

### Components (20)

- **Static** (9): Button, Input, Textarea, Label, Card (compound), Badge, Separator, Alert (compound), Avatar (compound).
- **Forms** (3): Checkbox, Switch, Select (compound).
- **Overlays** (4): Dialog (compound), Drawer (4-side variant), Tooltip, Popover.
- **Menus + feedback** (2): DropdownMenu (with nested Submenu + checkbox/radio items), Toast (+ Toaster singleton container).
- **Navigation** (2): Tabs, Accordion.

### Gem

- `wabi:install` + `wabi:add` + `wabi:list` + `wabi:registry` Rails generators.
- `Wabi::Base` Phlex base class with CVA-style `variants` DSL and variant-aware `merge_class` Tailwind dedup (`focus-visible:`, `data-[state=…]:`, axis-aware, width-vs-color for `border`/`ring`/`text`/`outline`/`divide`).
- `Wabi::RegistryClient` with disk cache, dev-context cache bypass (file://, localhost).
- `Wabi::Lockfile` tracking installed components.
- `Wabi::TurboStreamExtensions` adds `turbo_stream.wabi_toast(...)` when Turbo is loaded.
- Tailwind 4 native — `@theme inline` + `@custom-variant dark`, no preset.js.

### Registry

- Build pipeline produces `dist/r/<name>.json` per component + `index.json`.
- JSON Schema validation (`schema/component.v1.json`).
- 20 components installable via `bin/rails g wabi:add <name>`.

### Accessibility

- All overlays toggle the `inert` attribute via Zag's `onOpenChange` callback (synchronous inside the state transition, lands before `setInitialFocus`). Closed overlays are out of the tab order and the accessibility tree.
- `data-state` driven CSS transitions (opacity / translate / pointer-events) — no `display:none` cuts transitions short.
- WCAG-AA targeted per component manifest.

### Theming

- Default theme ships in `app/assets/tailwind/wabi/tokens.css` via `wabi:install`.
- `data-mode="dark"` toggles dark palette; `data-theme="…"` ready for multi-palette in v0.2.

### Tooling

- `bin/dev` monorepo entrypoint clears stale `docs/tmp/pids/server.pid` on launch.
- CI verifies all 20 dist artifacts on push (`.github/workflows/registry-build.yml`).
- Registry spec suite: 119 examples, 0 failures.
- Gem spec suite: 64 examples, 0 failures.

### Documentation

- `docs/SMOKE-TEST.md` records per-sprint outcomes and Zag.js 1.x trap memos (entries 1–10 in `feedback_zag_js_pattern`).
- `docs/V01-CARRYOVER.md` tracks v0.1 carryover (now closed) plus v0.2 deferrals.

### Known v0.2 deferrals

- `@zag-js/toast` group machine (`max` / `gap` / pause-on-group-hover). Current vanilla controller per toast covers the 99% case.
- Real portal pattern (Stimulus loses target tracking when subtree moves to `document.body`). Workaround: `position: fixed` + high z-index.
- Multi-palette theme picker UI + documented theme-extension flow.
- `wabi:update` diff-aware generator (current `wabi:install --force` is the minimum acceptable for v0.1).
- Multi-level DropdownMenu nesting (sub-inside-a-sub). v0.1 supports single-level submenus.
- `tailwind-merge`-equivalent class dedup for edge cases (`bg-cover` collapsing under `bg-{color}` etc.).
- Phlex 2.4.1 emits Ruby 4.0.5 warnings at load time; wait for upstream fix.
