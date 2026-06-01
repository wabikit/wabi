# Changelog

All notable changes to Wabi land here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.9.0 - 2026-05-31

DX + polish, plus a full fix of the vertical Slider.

### Breaking

- **Slider `marks:` moved from `Slider` to `SliderControl`.** Marks now render
  inside the control (the track's positioning context) so they align with the
  track in both orientations. Update `Slider.new(marks: […])` →
  `SliderControl.new(marks: […])` (and pass `orientation:` to `SliderControl`
  for vertical). Marks were introduced in v0.8.

### Features

- **`wabi:update` three-way merge.** Locally-edited component files are now
  3-way merged (base + local + new) via `git merge-file` instead of the
  all-or-nothing prompt: non-conflicting registry changes auto-apply while your
  edits are preserved; true conflicts are written with `<<<<<<<` markers. Falls
  back to the y/n/d/q prompt when git is unavailable or the lockfile predates
  this release. The lockfile now records `{ hash, content }` per file
  (back-compat: legacy string-hash entries still load and use the fallback). A
  data-safety guard never writes a file when `git merge-file` errors.
- **Combobox async error state.** New optional `ComboboxError` slot (hidden,
  `aria-live`) — shown on async fetch failure (prior results kept), hidden on
  the next successful fetch.

### Fixes

- **Vertical Slider now works end-to-end.** The v0.8 slider was effectively
  horizontal-only; the vertical orientation didn't render usably. Fixed across
  the board, each gated by orientation so horizontal is unchanged:
  - `SliderControl` fills the column height in vertical (was collapsing to 0,
    leaving the track 0px tall).
  - Thumb centers on the cross-axis correctly per orientation (horizontal:
    vertical-center; vertical: horizontal-center on the rail).
  - `SliderRange` fill is `w-full` in vertical (was zero-width / invisible) with
    Zag driving the height from the value.
  - Marks render inside `SliderControl`, aligned with the track (below it for
    horizontal, beside it spanning its height for vertical), with the tick +
    label offset oriented accordingly.

### Deferred to v0.10

- Toast `@zag-js/toast` group machine (high-risk; failed twice).
- Phlex 2.4 Ruby 4 warnings (upstream).

## 0.8.0 - 2026-05-31

Focused high-value mix: one marquee feature, one self-contained feature, an
accessibility win, and an overlay-controller hardening refactor. No breaking
changes.

### Features

- **Combobox async items.** With `url:` set, the combobox debounces input and
  fetches a server-rendered `ComboboxItem` fragment (AbortController-guarded so
  stale in-flight responses are dropped), swaps it into the content, and
  rebuilds the Zag collection from the new DOM via `machine.updateProps`. New
  optional `ComboboxLoading` slot (shown during the fetch); empty state is
  server-rendered; fetch errors keep the prior results + `console.warn`.
  `param` (default `q`), `debounce` (default 250ms), and `min_length`
  (default 1) are configurable. Sync mode is unchanged.
- **Slider marks/ticks.** `Slider(marks: [{value:, label:}])` (or bare
  Integers) renders tick markers (short vertical lines) positioned via Zag
  `getMarkerProps`, with optional labels. Works single + range.

### Fixes

- **Slider is now fully functional + visible.** Several latent issues from the
  v0.6 slider are fixed together:
  - **Thumb + marks render.** `thumbAlignment: "center"` on the machine — the
    previous `"contain"` default gated thumb/marker visibility on a thumb-size
    measurement that never completed in the vanilla Stimulus setup (the machine
    starts before `render()` decorates the DOM with Zag's part ids), leaving
    the thumb knob and any marks `visibility: hidden`.
  - **Pointer interaction.** New `SliderControl` element carries Zag's
    `getControlProps` (`onPointerDown`), so click/drag on the track now sets the
    value live. Previously the slider was keyboard-only. `SliderControl` also
    provides the positioning context that vertically centers the thumb on the
    track (the root is a flex column with the label/marks, so an absolutely
    positioned thumb anchored to it floated above the bar).
  - **Hidden-input dedup.** `syncHiddenInputs` cleanup selector
    (`data-wabi--slider-hidden`) never matched the inputs `appendHidden` created
    via `dataset` (which emitted single-dash `data-wabi-slider-hidden`), so a
    new hidden input leaked on every render and the form value went stale.
    `appendHidden` now uses `setAttribute` with the matching double-dash name.
  - **Thumb styling.** Smaller (12px) thumb with a thinner border + subtle
    shadow; `bg-foreground` fill (adapts to theme: dark knob in light mode,
    light knob in dark mode).
  - **Composition note:** the track + thumb(s) now nest inside `SliderControl`
    (`Slider > SliderLabel + SliderControl(SliderTrack(SliderRange) + SliderThumb…)`).

### Accessibility

- **`motion-reduce:transition-none`** on Toast and the animated overlays
  (Dialog, Drawer, Popover, Tooltip, DropdownMenu, Select, Combobox content +
  Dialog/Drawer backdrops) — `prefers-reduced-motion` users get instantaneous
  enter/exit instead of slide/fade.

### Refactor / internal

- **`_shared/overlay_portal.js`** — Dialog, Popover, Tooltip, Select, and
  DropdownMenu now share `capturePortalRefs` / `attachToBody` / `restoreFromBody`
  (composition, not inheritance) instead of duplicating that boilerplate per
  controller. Behavior-preserving (each overlay browser re-smoked).
- DropdownMenu's closest-ancestor-sub lookup is deduped into `_parentMachineFor`
  (was inline in both `connect()` and `render()`).
- Overlay `disconnect()` now restores from `<body>` before unregistering from
  `WabiPortalRegistry`, so the registry recomputes its sibling cache on the
  post-move DOM. `data-wabi-sub-index` is cleaned up on DropdownMenu disconnect.

### Deferred to v0.9

- Toast `@zag-js/toast` group machine; `wabi:update` three-way merge; richer
  Combobox async error UX; vertical-orientation Slider mark label offset; Phlex
  2.4 Ruby 4 warnings (upstream).

## 0.7.0 - 2026-05-30

Quality + finish: 10 items closing v0.6 deferrals and v0.5 long-tail. No new
components; one breaking change.

### Breaking

- **Slider range hidden inputs** now use Rails-native bracket params
  (`name[min]` / `name[max]`) instead of v0.6's flat `name_min` /
  `name_max`. Apps consuming range params must update their strong params
  from `params.permit(:price_min, :price_max)` to
  `params.require(:price).permit(:min, :max)`. Single-thumb sliders are
  unchanged (`name=<value>`).

### Features

- **Combobox `ComboboxItemIndicator`** now wires through `getItemIndicatorProps`
  and toggles `hidden` based on the item's selected state (was unwired in v0.6).
- **Combobox per-item `disabled`** flag now works end-to-end: an item can carry
  `{ value, label, disabled: true }` and the controller passes `isItemDisabled`
  to the Zag collection so Zag stamps `data-disabled` on the matching `<li>` for
  the `data-[disabled]:*` Tailwind variants.
- **Command palette item selection closes the dialog.** The bridge controller
  listens at `document` level for `wabi--combobox:change` and filters by id
  linkage (`data-wabi--command-id`, read via `getAttribute` — the double-dash
  attribute does not round-trip through `dataset`) to survive the dialog portal
  move. The controllers are ordered `wabi--command wabi--dialog` so the bridge
  stamps the dialog content before the dialog portals it. The "Preview in v0.6"
  callout is removed.
- **Command auto-opens the combobox when the dialog opens** so item clicks work
  immediately, without typing first. The combobox builds its collection from the
  rendered items when no `items` value is supplied.
- **Toast Sonner-style animations.** Slides in from the right on enter and slides
  back out on exit — pure CSS transitions on `data-state`, no plugin dependency.
- **`window.wabiToasters[id]`** keyed registry (via a new `wabi--toaster`
  controller on the `<ol>`) for pages with multiple Toaster instances.
  `turbo_stream.wabi_toast(toaster_id: "alerts", ...)` targets a specific one.
  `window.wabiToaster` remains as a deprecated alias to the most-recently-
  connected toaster for back-compat.
- **DropdownMenu N-level submenus.** Sub-inside-sub nesting now works to
  arbitrary depth (v0.6 was single-level only). Each sub links to its closest
  ancestor sub or the root menu.

### Cleanup / Perf

- **Vestigial `*-target="portal"` wrappers removed** from the portal-using
  overlays (Dialog, Drawer, Command dialog). The wrapper was a v0.4 placeholder
  for `portal: false` mode and added no behavior in v0.5+. (Popover, Tooltip,
  DropdownMenu, and Select had already been cleaned in a prior refactor.)
- **`WabiPortalRegistry.applyInert`** caches the body-siblings list. The cache is
  invalidated only when register/unregister changes the portal node set;
  `onOpenChange` reuses the cache and just toggles the inert attribute.

### Deferred to v0.8

- Combobox async items (server-side fetching).
- Toast `@zag-js/toast` group machine retry.
- `wabi:update` three-way merge on conflict.
- Slider marks/ticks.
- Overlay controller boilerplate refactor (the overlay controllers share
  attach/restore boilerplate; the DropdownMenu ancestor-lookup is duplicated
  between `connect()` and `render()`).
- `motion-reduce:transition-none` on Toast (and overlays) for reduced-motion.
- `WabiPortalRegistry` unregister/restoreFromBody ordering tidy.

## 0.6.0 - 2026-05-28

### Features

- **Forms wave** — 7 new components bring Wabi to 27 total:
  - `Toggle` — pressable toggle button (Bold/Italic style). Distinct from
    Switch, which is the sliding control. Variants: appearance
    (default/outline) and size (default/sm/lg). Powered by `@zag-js/toggle`.
  - `RadioGroup` + `RadioGroupItem` + `RadioGroupIndicator` —
    single-select radio group with keyboard navigation via
    `@zag-js/radio-group`. Hidden `<input type="radio">` per item for
    form submission.
  - `ToggleGroup` + `ToggleGroupItem` — group of toggles. `type: :single`
    enforces single selection (radio-like with button styling);
    `type: :multiple` allows multiple simultaneous selections. Hidden
    inputs emitted by the controller (`name` for single, `name[]` for
    multiple).
  - `Slider` + `SliderLabel` + `SliderTrack` + `SliderRange` +
    `SliderThumb` — value picker. Accepts Integer (single thumb) or
    Array (range mode). Vertical orientation via
    `orientation: :vertical`. Range inputs submit as `name_min`/`name_max`.
  - `Combobox` + 8 sub-components — input with autocomplete dropdown.
    Static items only in v0.6 (async deferred to v0.7). Uses the
    Sprint 9 portal pattern as a non-modal anchored overlay. A sibling
    `<input type="hidden">` mirrors the selected value so form
    submission posts the value, not the typed label.
  - `Form` + `FormField` + `FormLabel` + `FormDescription` +
    `FormMessage` — Phlex wrapper over Rails' `form_with` helper.
    FormMessage auto-extracts ActiveModel errors via `model:` + `field:`
    kwargs, with `text:` override for explicit messages. FormLabel uses
    `for_:` (matching the standalone `Label` convention).
  - `Command` + 7 sub-components — Cmd+K palette. Composition of Dialog
    (modal) and Combobox (filterable list). The combobox controller is
    mounted on an inner wrapper so it can't overwrite the dialog's
    role / aria-modal / data-state attributes (a trap discovered during
    smoke testing — `spreadProps` from `@zag-js/vanilla` strips existing
    attrs). Selection-closes-palette is **deferred to v0.7** (the
    `wabi--command` bridge can't reach across the dialog portal yet).

### Docs

- Form docs page demonstrates a multi-field example (name + email + bio
  + newsletter checkbox + submit) with client-side validation and
  inline success / per-field error messages — no page reload.
- Sidebar preserves its scroll position across Turbo navigations and
  highlights the active component with `bg-accent + font-semibold +
  shadow-sm` via Tailwind's `aria-[current=page]:` arbitrary variant.
- Docs `Pagefind` indexer now derives `ROUTES_TO_INDEX` from
  `ComponentsController::ALL` instead of a hand-maintained list, so
  future component additions are crawled automatically.

### Deferred to v0.7

- Combobox async items (server-side fetching via Turbo Frame or
  callback).
- Combobox `ComboboxItemIndicator` wiring (exported but not consumed by
  the controller render loop).
- Combobox `disabled:` on individual items (data attribute is set but
  the collection doesn't pass `isItemDisabled`).
- Slider marks/ticks at specific track positions.
- Command palette item selection auto-closing the dialog (the
  `wabi--command` bridge listener doesn't cross the dialog portal —
  needs Stimulus Outlets or a document-level listener).
- Toast `@zag-js/toast` group machine retry + Sonner-style animations
  (carried over from v0.5).
- Overlay controller boilerplate refactor (the now-six overlay
  controllers share ~50 LOC of attach/restore + ref capture).
- Vestigial `wabi--<name>-target="portal"` wrappers cleanup.
- DropdownMenu multi-level submenu nesting.
- `wabi:update` three-way merge.

## 0.5.0 - 2026-05-27

### Breaking

- **Overlays portal to `document.body` by default**. Dialog, Drawer,
  Tooltip, Popover, DropdownMenu, and Select all move their content (and
  backdrop/positioner where applicable) to `<body>` on connect. Pass
  `portal: false` to keep v0.4 in-tree behavior. The shared
  `WabiPortalRegistry` JS module is now part of every overlay's wabi:add
  install — it lands at
  `app/javascript/controllers/wabi/_shared/portal_registry.js`.

### Features

- `wabi:update` generator. Per-component diff-aware updates with
  per-file conflict detection. Flags: `--force`, `--dry-run`. Reads
  and writes per-file SHA256 hashes in `wabi.lock.json` (additive
  schema; legacy lockfiles fall back to prompting on every file).
- Real portal pattern for the 6 overlays. Resolves the v0.1 carryover
  documented in `docs/V01-CARRYOVER.md` (#3). Overlays inside
  transformed/scrollable ancestors now position relative to the
  viewport.

### Docs

- `+esm` jsdelivr footnote added to 5 component pages
  (checkbox/select/switch/dialog/tabs) for parity with the other 5
  Zag-backed components.

### Deferred to v0.6

- Toast `@zag-js/toast` group machine. Attempted in v0.5 but reverted — the group machine's interaction with Phlex+Stimulus+Turbo caused an infinite render loop. v0.4 vanilla setTimeout controller restored; group features (max/gap/pause-on-group-hover/swipe) targeted for v0.6 with a different implementation strategy.
- Forms wave (RadioGroup/Toggle/ToggleGroup/Slider/Combobox/Command/Form).
- Nav wave (Sheet/ContextMenu/Pagination/NavigationMenu).
- Data wave (Calendar/DatePicker/DataTable).
- Three-way merge in `wabi:update`.
- Multi-level DropdownMenu nesting (sub-inside-sub).
- Phlex 2.4 Ruby 4 warnings (upstream).

## [0.4.0] — 2026-05-27

Sprint 8 — docs completeness + theme polish. The docs site gains the
three-column shell (grouped sidebar, content, right-side TOC) on every
`/docs/*` route, a Pagefind-powered search, and detail pages for the
remaining 16 components — every component in the registry now has its
own page. Theming gains a tinted secondary/accent per color palette,
a quick sun/moon mode toggle in the header, and a swap of `slate` +
`zinc` for `yellow` + `orange`.

### Added

- **`Components::Site::Sidebar` + `Sidebar::Group` + `Sidebar::Link`** — Grouped left navigation for `/docs/*`. 7 groups (Getting Started / Forms / Layout & Display / Overlays / Menus / Navigation / Feedback) listing all 20 components + the prose pages. Active link highlighted via `current_path:` kwarg.
- **`Components::Site::TableOfContents` + `site--toc` Stimulus controller** — Right-side TOC on `chrome: :full` pages. Empty `<aside>` filled client-side by scanning `main h2[id], main h3[id]`. Tracks the active section via `IntersectionObserver`.
- **`Components::Site::SidebarToggle` + `site--sidebar` controller** — Hamburger button visible below `lg` breakpoint; opens the sidebar as a fixed overlay with scroll lock + Escape-to-close.
- **`Components::Site::SearchBox` + `site--search` controller** — Header search input that lazy-loads PagefindUI as a classic script, mounts it on the input, and renders results as an absolute-positioned dropdown styled with Wabi popover tokens.
- **`Components::Site::ModeToggle`** — Sun/moon icon button next to the ThemePicker. One-click dark/light flip via the existing `wabi--theme#toggleMode` action.
- **`Wabi::Docs::Indexer` + `wabi:docs:index` rake task** — Crawls 26 docs routes via `Rack::Test` (with `HTTP_HOST=localhost` + Chrome UA to satisfy `ActionDispatch::HostAuthorization` and `allow_browser :modern`), writes the response HTML to files mirroring the URL structure, then shells out to `npx pagefind` to build the static index. Index lives at `docs/public/pagefind/` and ships in the repo — deploys stay Node-free.
- **`docs/spec/requests/docs_smoke_spec.rb`** — Request specs covering every documented route (3 chrome modes: bare / sidebar_only / full) and the SearchBox markup on non-bare routes.
- **16 new detail pages** under `/docs/components/`: checkbox, input, label, select, switch, textarea, alert, avatar, badge, card, separator, drawer, popover, tooltip, accordion, toast. Each follows a single canonical anatomy: Installation / Example (ComponentPreview) / Source / Accessibility.
- **Two new theme palettes**: `yellow` (vibrant amber primary) and `orange`. Both follow the standard light + dark structure.
- **`Site::Layout(chrome:)` kwarg** — `:bare` (default, no sidebar/TOC), `:sidebar_only`, `:full`. Drives where the sidebar, TOC, and SearchBox render. 11 views updated to pass the appropriate value.
- **`ROADMAP` updates** + **README "Working on docs" section** documenting the Pagefind workflow.

### Changed

- **Theme palettes**: `slate` and `zinc` replaced with `yellow` and `orange`. Neutral baselines stay covered by `default` and `stone`.
- **Theme tinting**: the 6 color palettes (rose, blue, green, violet, yellow, orange) now redefine `--secondary` and `--accent` as pale tints of their primary hue (lightness ~92-96% light / ~18% dark) with foreground colors at the same hue darkened/lightened for AA contrast. Default and Stone stay neutral on purpose. `--muted` stays neutral across all themes.
- **Theme dark-mode propagation**: each theme's dark block now also matches `[data-mode="dark"] [data-theme="X"]:not([data-mode="light"])`, so dark mode cascades into nested `data-theme` cards (e.g. the `/docs/themes` palette grid).
- **Button `:outline` appearance**: `border-input` (neutral) replaced with `border-primary` + `text-primary`. Outline buttons now adopt the active theme color on their stroke and label.
- **`Site::ComponentPreview`**: replaced the ad-hoc `site--preview-tabs` Stimulus controller with the real `Wabi::UI::Tabs` (dogfooding). Switcher uses an underline pattern — active trigger gets a 3px primary-colored bottom border + bold primary-color text.
- **`Site::CodeBlock` copy button**: word "Copy" replaced with a 14px clipboard SVG inside a 28×28 button. On copy: swap to checkmark SVG for 1.2s. `pre` reserves the button's column with `pr-12` so long code lines never tuck under the button while scrolling.
- **Components index**: every component links to its detail page. The `DETAILED` constant gate was dropped from `ComponentsController#show`; the only guard is membership in `ALL`.
- **Site::Layout header**: sticky with `z-30`, gains the SearchBox + ModeToggle on `chrome != :bare` routes.

### Fixed

- **Tailwind 4 migration — explicit `border` width on every `border-input` element.** TW3 implicitly set `border-width: 1px` on any element with a `border-{color}` class; TW4 removed that default. Components that only declared `border-input` rendered with width 0 — no visible outline. Affected: `select_trigger`, `select_content`, `dropdown_menu_content`, `dropdown_menu_sub_content`, `drawer_content` (4 side variants), `dialog_content`, `popover_content`, `toast`.
- **Tailwind 4 migration — cursor: pointer on interactive elements.** TW4 Preflight removed the legacy default on `<button>`. Added a CSS rule under `_shared.css` (`@layer base`) restoring `cursor: pointer` for `button`, `[role="button"/"switch"/"checkbox"/"tab"/"option"/"menuitem"/"menuitemradio"/"menuitemcheckbox"]`, plus `cursor: not-allowed` for `[disabled]` and `[aria-disabled="true"]`.
- **`Wabi::UI::TabsTrigger` active state**: switched all `data-[state=active]:*` variants to `aria-selected:*`. Zag.js's tabs API emits `aria-selected="true"` + `data-selected=""`, NOT `data-state="active"` — so the active styling never fired. Affected `TabsTrigger` base tokens (both light and dark mode active styles).
- **`Avatar` image/fallback overlap**: `AvatarImage` is now `absolute inset-0 object-cover` so it stacks over `AvatarFallback`. Previously both rendered as flow-positioned siblings inside the flex Avatar container.
- **`Toast` sticky mode**: `wabi--toast` controller treats `durationMsValue <= 0` as "no timer" — toasts render persistently until manually dismissed. The Toast detail-page preview now uses this so the 3 appearances stay visible.
- **`SidebarToggle` Stimulus wiring**: button declared `data-action` but no element declared `data-controller="site--sidebar"`, so the controller never instantiated and the hamburger didn't open the sidebar. Added `data-controller` to the button itself.
- **TOC anchor jumps**: sticky 56px header was tapping over scrolled-to headings. Added `scroll-margin-top: 5rem` to `main :is(h1, h2, h3, h4, h5, h6)[id]`.
- **SearchBox PagefindUI loader**: PagefindUI ships as classic IIFE scripts (sets `window.PagefindUI`), not ES modules. The original `await import("/pagefind/pagefind-ui.js")` returned an empty module. Rewrote the loader to inject a `<script>` tag and await its `load` event.
- **Search result URLs**: Indexer wrote `docs_components_button.html` (flattened with `_`), and Pagefind built result URLs from those filenames. Now writes files mirroring the URL structure (`docs/components/button.html` with `mkdir_p`) and PagefindUI's `processResult` callback strips `.html` from the displayed URL — clicks navigate to `/docs/components/button` directly.
- **Select example wiring**: `items:` array was missing on the `/docs/components/select` example, so Zag's collection was empty and clicks on SelectItem elements were no-ops. Added a `FRUITS` array passed via `items:` and iterated for the SelectItem children.

### Spec totals

- Registry: **125/125**.
- Gem: **66/66**.
- Docs (request + component specs): **40/40** — every smoke route (`:bare` / `:sidebar_only` / `:full`) returns 200 with the expected sidebar/TOC/search markup; Indexer crawl writes one file per route, mirroring URL structure with `index.html` at root.

### Known v0.4 deferrals → v0.5

- `@zag-js/toast` group machine — Wabi v0.4 Toast still uses a vanilla setTimeout-based controller. v0.5 will adopt the real Zag toast group machine for cross-toast coordination (max visible, stacking, etc.).
- `wabi:update` generator — Pulling registry updates back into a host app is still manual (re-run `wabi:add <name>`). v0.5 will add a generator that diffs registry vs. host and applies changes.
- Real portal pattern — Overlay components (Dialog, Drawer, Popover, Tooltip) currently render in-tree. A `<dialog>`-element-based or `Components::UI::Portal`-based pattern is queued for v0.5.
- Backfill `bin/importmap pin` footnote on the 5 pre-existing Zag pages (checkbox, select, switch, dialog, tabs). v0.4 added the warning to the new overlay/accordion pages; sweep across all pages happens in v0.5 docs polish.

---

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
