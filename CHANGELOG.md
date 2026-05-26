# Changelog

All notable changes to Wabi land here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] — 2026-05-26

Sprint 7 (docs site polish). The docs site stops being a one-page kitchen
sink and starts behaving like real documentation: marketing landing,
components index, detailed pages for the 4 exemplar components, and
prose docs for onboarding / theming / philosophy. Sprint 8 (v0.4) is
queued to fill in the remaining 16 component detail pages + Pagefind
search.

### Added

- **`Components::Site::CodeBlock`** — Phlex `<pre><code>` wrapper with server-side Rouge syntax highlighting and a clipboard-copy button. Backed by a tiny `site--copy` Stimulus controller that hands the literal source (not the highlighted HTML) to `navigator.clipboard`.
- **`Components::Site::ComponentPreview`** — Tabbed Preview/Code view around an example. Block-provided live render in the Preview tab; literal source string rendered via CodeBlock in the Code tab. Backed by `site--preview-tabs` Stimulus controller that toggles panels and flips `data-active` on the tab buttons.
- **`ComponentsController` + `/docs/components` index** — Routes a components landing that lists all 20 v0.2 components with their manifest-derived descriptions. Cards for the 4 exemplars with detailed docs (Button / DropdownMenu / Dialog / Tabs) link out; cards for the remaining 16 show description + a "Source only" affordance until v0.4 fills them in. Nav header gains a "Components" link.
- **4 detailed component doc pages**: `/docs/components/button` (single-element variants), `/docs/components/dropdown_menu` (compound with submenu), `/docs/components/dialog` (overlay), `/docs/components/tabs` (in-flow navigation). Each ships: breadcrumb back-link, title, description, installation snippet, live `ComponentPreview` example, Source `CodeBlock(s)` reading the actual .rb files at request time, Accessibility bullets.
- **Marketing landing at `/`** — Hero ("Beautifully imperfect components for Rails") with Get-started + Browse-components CTAs, theming-aware live demo (two Cards that repaint with the theme picker), 30-second install snippet, "Why Wabi" 3-up feature grid, footer.
- **`/preview`** — The Sprint 1-6 kitchen sink home is preserved verbatim here for dev-time component browsing. 22 component demo sections.
- **`/docs/getting-started`** — 5-step onboarding (gem add → install generator → wire Tailwind 4 → mount theme controller → add components). Cross-links to /docs/components, /docs/theming, /docs/themes, /docs/philosophy.
- **`/docs/theming`** — How to switch palettes, available palette list, dark-mode toggle pattern, customizing tokens (HSL var space), Tailwind 4 notes (no preset.js, `@theme inline`, `@source` for autodetection).
- **`/docs/philosophy`** — 5-section rationale: "you own the code", Phlex-native composition, accessible-by-default, brand-neutral, Hotwire-friendly.

### Changed

- **Dependencies**: `docs/Gemfile` gains `rouge ~> 4.5` for server-side syntax highlighting in `CodeBlock`. No new gems beyond that.
- **`docs/app/views/pages/home.rb` REPLACED** with the marketing landing; the old kitchen-sink home was moved to `docs/app/views/pages/preview.rb` (class renamed `Home` → `Preview`) and routed at `/preview`.
- **Nav layout**: header gains a "Components" link alongside the existing "Themes" link. ThemePicker dropdown stays.

### Fixed

- **Constant resolution shadow under `Views::Pages::Components`.** Introducing the new `Views::Pages::Components::*` namespace (for the components index and 4 detailed pages) shadowed the top-level `Components::*` from anything else under `Views::Pages`. Ruby's constant lookup found `Views::Pages::Components` first and failed to find `Site` or `UI` inside it. Three views needed leading-`::` prefix on their `render` calls: `Home`, `Preview`, `Themes`. The `Themes` view (Sprint 6) had been silently broken since the components namespace was introduced — discovered and fixed in the same task.

### Spec totals

- Registry: 125/125 unchanged (Sprint 7 doesn't touch registry).
- Gem: 66/66 unchanged.
- Doc-site smoke (Rack::Test): 11/11 routes return 200 — `/`, `/preview`, `/docs/themes`, `/docs/components`, `/docs/components/{button,dropdown_menu,dialog,tabs}`, `/docs/getting-started`, `/docs/theming`, `/docs/philosophy`.

### Known v0.3 deferrals → v0.4

- **Detailed doc pages for the remaining 16 components** (input, textarea, label, card, badge, separator, alert, avatar, checkbox, switch, select, drawer, tooltip, popover, toast, accordion). The index lists them with descriptions + "Source only" affordance; v0.4 fills in the per-component pages.
- **Pagefind static search** — Needs Node/bun + pre-rendered HTML. Not yet worth the infrastructure for ~25 docs pages.
- **Sidebar nav** with active-section state — Header-only nav is fine for 5 top-level pages; sidebar makes sense once components have their own subsection.
- Same v0.2 deferrals still standing: `@zag-js/toast` group machine, real portal pattern, `wabi:update` generator, multi-level DropdownMenu nesting, `tailwind-merge`-equivalent class dedup edge cases, Phlex 2.4.1 Ruby 4 warnings.

---

## [0.2.0] — 2026-05-26

Sprint 6 (themes). 8 palettes ship, live theme switcher in the docs nav,
`/docs/themes` gallery page, and a `wabi:theme <slug>` generator to swap
themes in user apps. Sprint 7 (docs polish — per-component doc pages,
Pagefind search, marketing landing) is the next planned milestone.

### Added

- **7 new theme palettes**: slate, stone, zinc, rose, blue, green, violet. Light + dark per theme, scoped via `[data-theme="<slug>"]` and `[data-theme="<slug>"][data-mode="dark"]` selectors. Default theme stays as the bare `[data-theme="default"]` (plus `:root` for the no-theme-yet case).
- **`bin/rails g wabi:theme <slug>` generator**: fetches `_shared.css` + `<slug>.css` from the lockfile's registry (HTTP or `file://`), concatenates, and overwrites `app/assets/tailwind/wabi/tokens.css`. Hint printed to re-run `tailwindcss:build`.
- **`Components::Site::ThemePicker`**: DropdownMenu in the docs nav with the 8 themes as a RadioGroup + a "Toggle dark mode" item. Wired to the existing `wabi--theme` Stimulus controller (`setTheme`/`toggleMode`), so persists in localStorage across reloads.
- **`/docs/themes` gallery**: side-by-side cards painting with each palette's own colors (each card carries its own `data-theme`). Each has an "Apply this theme" button that propagates the choice globally.
- **Registry endpoint `/r/themes/:slug.css`**: serves the per-theme CSS file. Slug regex allows the `_shared` underscore-prefixed name plus regular slugs. Realpath check guards against directory traversal.
- **`registry/themes/` directory + builder integration**: new canonical home for theme files. `Wabi::Registry::Builder#build_themes` runs as part of every `bin/build` and regenerates two derived artifacts:
  - `gem/templates/tokens.css` — `_shared.css` + `default.css` only (what `wabi:install` copies into user apps).
  - `docs/app/assets/tailwind/wabi/tokens.css` — `_shared.css` + all 8 themes concatenated (powers live switching in the docs site).

### Fixed

- **DropdownMenuItem / DropdownMenuRadioItem dropped user-supplied `data:` kwargs.** Both components extracted only `:class` from `@attrs`, silently discarding everything else. Surfaced when wiring ThemePicker's `data: { action: "click->wabi--theme#setTheme", ... }` and the action attribute never reached the DOM. Both components now merge user data with component data; component keys win on collision so caller-supplied attrs can't override target/value bindings. Two new regression specs lock this in.
- **CSS specificity bug: `:root` redefined per theme clobbered light-mode switching.** First pass had every theme file start with `:root, [data-theme="<slug>"]`. When concatenated for the docs site, `:root` appeared 8 times. Since `:root` and `[data-theme="X"]` have equal specificity (0,1,0), the later `:root` block (from violet, last in concat order) overrode every earlier `[data-theme="X"]` rule — so every light-mode theme repainted as violet. Dark mode escaped because `[data-theme="X"][data-mode="dark"]` has specificity (0,2,0). Fix: only `default.css` keeps the `:root, ` prefix; the other 7 themes use `[data-theme="<slug>"]` alone. Regression spec asserts exactly one `:root` block in the docs output.

### Changed

- **Default theme location moved** from `gem/templates/tokens.css` (hand-maintained) to `registry/themes/default.css` (canonical source) + `_shared.css` (boilerplate). The gem template is now a build artifact, regenerated by `bin/build`. Users see no functional difference; gem upgrades carry the same default palette as before.
- **Site::Layout grew a `<header>`** with a "Wabi" home link, a "Themes" nav link to `/docs/themes`, and the theme picker. The `raw safe(yield_content(&block))` + `<Toaster>` body siblings are preserved exactly.

### Spec totals

- Registry: 125 examples, 0 failures (was 119 at v0.1; +6 across `#build_themes` describe block + DropdownMenu user-data merge specs).
- Gem: 66 examples, 0 failures (was 64; +2 from `theme_generator_spec`).

### Known v0.2 deferrals → v0.3

- Pagefind static search.
- Per-component documentation pages (20 routes).
- Marketing-oriented landing page; kitchen-sink home would move to `/preview`.
- Getting-started / philosophy / theming concept prose pages.
- `@zag-js/toast` group machine (max stack, gap/offset, pause-on-group-hover).
- Real portal pattern for transformed ancestors.
- `wabi:update` diff-aware generator (`wabi:install --force` is the current minimum).
- Multi-level DropdownMenu nesting (v0.2 still supports single-level submenus).
- Phlex 2.4.1 Ruby 4 warnings (wait for upstream fix).

---

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
