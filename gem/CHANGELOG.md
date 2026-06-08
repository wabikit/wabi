# Changelog

All notable changes to Wabi land here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.24.3 - 2026-06-07

### Fixed
- **Splitter:** dragging the gutter now resizes the panels. Zag initializes panel
  sizes (`syncSize`) at start, but bails when the root has no layout yet — inside an
  inactive tab panel, below the fold, or a closed overlay — leaving the sizes empty
  so a drag had no base to resize from (the gutter showed a resize cursor but
  nothing moved). The controller now re-syncs sizes via `IntersectionObserver` once
  the splitter is visible. Same class of fix as Carousel in 0.24.2.

Component count unchanged (47).

## 0.24.2 - 2026-06-07

### Fixed
- **Collapsible:** the content now actually expands/collapses. Zag nulls the
  content's `data-state` once open + settled (its canonical animation keys off a
  `--height` variable), which left our `grid-rows` height transition stuck closed;
  the controller now re-asserts `data-state` from the open state so the animation
  runs.
- **Carousel:** prev/next now scroll the slides. Zag computes scroll-snap points
  right after start, but when the carousel isn't laid out yet (inside an inactive
  tab panel, below the fold, or a closed overlay) the points collapsed to ~0 and
  navigation moved only the indicators. The controller now refreshes the snap
  points via `IntersectionObserver` once the carousel becomes visible.

Component count unchanged (47).

## 0.24.1 - 2026-06-07

### Fixed
- **Navigation Menu:** dropdown panels now portal to `<body>` and are positioned
  `fixed` under their trigger, so they are no longer clipped by `overflow-hidden`
  or stacking-context ancestors (e.g. inside cards/previews). Hover-to-panel and
  click-outside dismiss are unchanged. Component count unchanged (47).

## 0.24.0 - 2026-06-06

Four new components (43 → 47), all backed by Zag.js 1.41 via `@zag-js/vanilla`.

### Added

- **Collapsible** (`collapsible`, `@zag-js/collapsible`). Toggle the visibility of a content
  region with a smooth height animation (the `grid-rows-[0fr]→[1fr]` trick, no keyframes;
  respects `prefers-reduced-motion`). `open` / `disabled`.
- **Splitter** (`splitter`, `@zag-js/splitter`). Resizable side-by-side panels with draggable
  gutters, horizontal or vertical. Panels are configured via a `panels:` array
  (`[{ id:, minSize?, maxSize? }]`); each gutter is a `role="separator"` keyboard-resizable
  with arrow keys / Home / End. The Splitter fills its (sized) parent.
- **Carousel** (`carousel`, `@zag-js/carousel`). Slideshow with snap scrolling, prev/next
  controls, indicators, and optional autoplay. `slide_count` (required), `slides_per_page`,
  `slides_per_move`, `loop`, `orientation`, `autoplay`.
- **Navigation Menu** (`navigation_menu`, `@zag-js/navigation-menu`). Top-level site
  navigation with per-item dropdown panels that open on hover and keyboard focus. Rendered
  in-tree; closed panels are `inert` (removed from the tab order and a11y tree).

## 0.23.0 - 2026-06-06

Three new components (40 → 43), all backed by Zag.js 1.41 via `@zag-js/vanilla`.

### Added

- **Rating Group** (`rating_group`, `@zag-js/rating-group`). Star rating input with
  half-star precision (`allow_half`), a read-only display mode (`read_only`), and a
  configurable star `count` (default 5). Each star is two layered SVGs — an always-visible
  outline plus a filled overlay revealed via `group-data-[highlighted]` and clipped to the
  left half via `group-data-[half]` — so half-stars render in pure CSS. Submits the value
  through Zag's hidden input (`name`).
- **Hover Card** (`hover_card`, `@zag-js/hover-card`). Rich preview card shown on pointer
  hover and keyboard focus of a trigger, rendered through a portal (reusing the shared
  `_shared/overlay_portal` helper). Configurable `open_delay` / `close_delay`; content is
  inert while closed and fades in (respecting `prefers-reduced-motion`). Non-modal — no
  focus trap. The trigger is keyboard-focusable before hydration (`tabindex="0"`).
- **Tags Input** (`tags_input`, `@zag-js/tags-input`). Multi-value text entry that collects
  free-form tags, with edit-in-place (`editable`), an optional `max`, and a placeholder.
  Tag nodes are rendered by the controller at runtime from the machine's value collection.
  Submits as a Rails array via per-tag `name[]` hidden inputs, re-synced on every change
  with no leaked inputs.

### Fixed

- **README component table** brought current — it still listed 36 components and omitted the
  v0.22.0 additions (DatePicker, InputOTP, FileUpload, ContextMenu). Now reflects all 43.

## 0.22.0 - 2026-06-05

Four new components (36 → 40), all backed by Zag.js 1.41 via `@zag-js/vanilla`.

### Added

- **Date Picker + Calendar** (`date_picker`, `@zag-js/date-picker`). A localized date
  field (input + popover calendar) and a standalone inline `Calendar`. Single and range
  selection; the day grid is built from the machine at runtime; submits ISO `YYYY-MM-DD`
  via hidden inputs (single → `name`; range → `name[start]` + `name[end]`). The range
  shows a connecting band between the start/end days (plus a hover preview). The field
  input has an accessible name (`aria-label`, default "Choose date", overridable).
- **Input OTP** (`input_otp`, `@zag-js/pin-input`). One-time-code / PIN input — N
  single-character slots (default 6) that submit a single concatenated hidden value.
  `length`, `type` (`:numeric` / `:alphanumeric`), `mask`, and `otp`
  (`autocomplete="one-time-code"`) are configurable.
- **File Upload** (`file_upload`, `@zag-js/file-upload`). Drag-and-drop dropzone + browse
  button + a file list (name, size, remove, image thumbnail) rendered from the accepted
  files. Backed by a real `<input type="file">` so a standard Rails multipart submit posts
  the files; `name` gains `[]` and `multiple` when `max_files > 1`. `accept` / `max_size`
  constraints supported.
- **Context Menu** (`context_menu`, `@zag-js/menu`). Right-click menu opening at the
  cursor, with full DropdownMenu parity — items, label, separator, shortcut, checkbox and
  radio items, and N-level submenus.

### Deferred

- Date Picker: multi-month side-by-side view (range still spans months via prev/next).
- Input OTP: groups + separator (e.g. 3-3).
- File Upload: ActiveStorage direct-upload, chunked/resumable uploads, progress bars.

## 0.21.3 - 2026-06-05

### Accessibility

- **`SidebarTrigger` now announces state.** It registers as a `wabi--sidebar`
  controller target, and the controller reflects `aria-expanded` (expanded vs.
  collapsed on desktop, off-canvas open vs. closed on mobile) and points
  `aria-controls` at the sidebar panel (which is given a stable id).
- **Mobile panel is a proper modal.** When the sidebar opens off-canvas on mobile
  it becomes `role="dialog"` with `aria-modal="true"` (cleared on close); the panel
  also carries a default `aria-label` ("Sidebar"), overridable via `aria-label:`.
- **`⌘/Ctrl+B` is scoped.** The toggle shortcut is now ignored while focus is in an
  `input`, `textarea`, `select`, or `contenteditable` element, so it no longer
  collides with editors' bold shortcut.

### Changed

- **Docs:** the sidebar page now shows the shell variants (floating / inset)
  directly under the main example, matching the other component pages.

## 0.21.2 - 2026-06-04

### Added

- **Collapsible `<details>` open/close animation.** `SidebarMenuCollapsible` and
  collapsible `SidebarGroup`s now slide open/closed when the sidebar is expanded — a
  CSS-only progressive enhancement (`::details-content` + `interpolate-size`), gated
  to `[data-state="expanded"]` so collapsed mode (flyout / icon rail) is untouched.
  Browsers without support fall back to the instant native behavior.

## 0.21.1 - 2026-06-04

### Added

- **Collapsed-submenu flyout.** When the sidebar is collapsed to icons, hovering or
  focusing a `SidebarMenuCollapsible` group pops its submenu out as a floating panel
  anchored to the icon (auto-flipping to the other side near the viewport edge),
  instead of hiding it. Expanded mode keeps the inline `<details>` behavior. A small
  `wabi--sidebar-flyout` controller repositions the same submenu with `position:
  fixed` (so it escapes the rail's clipping); hover/focus open, Escape / pointer-leave
  close. Desktop only.

## 0.21.0 - 2026-06-04

### Added

- **`SidebarRail`** — a thin, desktop-only strip on the sidebar's inner edge;
  clicking it toggles collapse/expand (it reuses the `wabi--sidebar` controller, so
  the rail, `SidebarTrigger`, and ⌘/Ctrl+B all drive the same toggle). `side:` picks
  the edge; a 1px line highlights on hover/focus. Render it inside `Sidebar`.

## 0.20.0 - 2026-06-04

Sidebar v3 — richer menu items, shell variants, and polish. No breaking changes.

### Added

- **Shell variants** on `SidebarProvider`: `variant: :floating` (the rail becomes a
  detached, rounded, shadowed card) and `variant: :inset` (the main content, wrapped
  in the new **`SidebarInset`**, floats as a rounded card over a sidebar-colored
  background). Default stays `:sidebar`.
- **Collapsible groups** — `SidebarGroup.new(collapsible: true, label: "…", default_open: true)`
  renders the group as a native `<details>` disclosure (label as summary, rotating
  chevron, no JS).
- **`SidebarInput`** — a search field styled for the sidebar (hidden in collapsed mode).
- **`SidebarMenuSkeleton`** — a loading-row placeholder (icon + text pulse;
  `show_icon:` toggles the icon).

### Fixed

- **`SidebarMenuButton` / `SidebarMenuSubButton` now forward arbitrary attributes**
  (`id`, `target`, `rel`, `aria-*`, `data-*`, `data-turbo-method`, …) to the rendered
  `<a>`/`<button>` — they were previously dropped. For tooltip menu buttons, a
  user-supplied `data:` is merged with the internal tooltip-trigger target so neither
  is lost.

## 0.19.1 - 2026-06-03

### Fixed

- **Sidebar collapsed-only tooltips showed when expanded too.** The menu-button
  tooltip's content portals to `<body>` (Zag default), which escaped the
  `group/sidebar` scope, so the `group-data-[state=expanded]/sidebar:hidden` gate
  never matched and the label tooltip appeared even when the rail was expanded
  (redundant with the visible label). The `wabi--sidebar` controller now mirrors
  collapse state to `<html data-wabi-sidebar="…">` (same idiom as the theme
  controller's `data-mode`), and the tooltip content gates on that marker — which
  reaches the portaled content. Tooltips now appear only when collapsed.

## 0.19.0 - 2026-06-03

Sidebar v2 — a richer, themeable Sidebar. No breaking changes (existing v1
sidebars keep working and pick up the new surface tokens).

### Added

- **Dedicated `--sidebar*` color tokens** (full shadcn-style palette: `--sidebar`,
  `--sidebar-foreground`, `--sidebar-primary(-foreground)`, `--sidebar-accent(-foreground)`,
  `--sidebar-border`, `--sidebar-ring`) across all 8 themes (light + dark). The
  sidebar now reads as its own surface; the tokens are exposed as `bg-sidebar`,
  `text-sidebar-foreground`, `bg-sidebar-accent`, `border-sidebar-border`,
  `ring-sidebar-ring`, etc., and are independently re-themeable.
- **⌘/Ctrl+B** toggles the sidebar (collapse on desktop, open/close on mobile).
- **Nested submenus** — `SidebarMenuCollapsible` (native `<details>`, no JS) with
  `SidebarMenuSub`/`SidebarMenuSubItem`/`SidebarMenuSubButton`. Expand inline when
  the rail is expanded; hidden in collapsed (icon) mode. The chevron rotates on open.
- **`SidebarMenuBadge`** — a trailing count badge (hidden in icon mode).
- **`SidebarMenuAction`** — a secondary per-item button revealed on hover/focus
  (hidden in icon mode).

### Changed

- `Sidebar`, `SidebarMenuButton`, and `SidebarTrigger` recolored to the new
  `--sidebar*` surface tokens (active/hover use `--sidebar-accent`); `SidebarMenuItem`
  is now a `group/menu-item` hover context for badges/actions.

## 0.18.0 - 2026-06-03

Adds the **Sidebar** component (#36).

### Added

- **Sidebar.** A composable, collapsible application sidebar: collapses to an
  icon rail on desktop (toggle persisted in `localStorage`) and becomes an
  off-canvas panel on mobile (focus moves into it, the rest of the page goes
  `inert`, Escape / backdrop click closes). Anatomy: `SidebarProvider`, `Sidebar`
  (`side: :left | :right`), `SidebarTrigger`, `SidebarHeader`/`SidebarContent`/
  `SidebarFooter`, `SidebarGroup`/`SidebarGroupLabel`, `SidebarMenu`/
  `SidebarMenuItem`/`SidebarMenuButton`. Menu buttons render as real `<a>`/`<button>`
  (active item gets `aria-current="page"`) and show a tooltip with their label when
  the rail is collapsed (reuses the Tooltip component). State is set once on the
  provider and propagated via a `group/sidebar` data-attribute marker; the
  `wabi--sidebar` Stimulus controller is custom (no Zag). Install with
  `bin/rails g wabi:add sidebar` (pulls `tooltip`).

  Caveat: variant/state is propagated through a Tailwind named group
  (`group/sidebar`), which matches any ancestor of that name — avoid nesting a
  `Sidebar` inside another `Sidebar`.

## 0.17.0 - 2026-06-03

A minimalist `:underline` style variant for Tabs.

### Added

- **Tabs `:underline` variant.** `Tabs.new(variant: :underline)` renders a
  full-width, minimalist tab strip: no track, a baseline border under the whole
  list, and the active tab marked by a primary-colored bottom border + primary
  bold text (with a transparent placeholder border so activation doesn't shift
  layout). Joins `:standard` (default) and `:pill`; set once on the root and
  propagated to `TabsList`/`TabsTrigger` via the `group-data-[variant=underline]`
  marker.

  Note: the variant is set on the `Tabs` root and applied to its pieces via a
  Tailwind named group (`group/tabs`), which matches any ancestor of that name —
  so a `Tabs` nested inside another `Tabs` inherits the outer variant. Avoid
  nesting tabs of different variants (or give the inner one its own wrapper).

## 0.16.0 - 2026-06-03

Local Zag vendoring for offline / strict-CSP installs, plus a `:pill` style
variant for Tabs.

### Added

- **`wabi:vendor` generator — opt-in local vendoring of Zag (offline / strict-CSP).**
  Components pin Zag from the jsDelivr `+esm` CDN by default, which fails for
  offline, air-gapped, or strict-CSP apps. `bin/rails g wabi:vendor` reads the
  jsDelivr `+esm` pins from `config/importmap.rb`, downloads the full transitive
  `+esm` graph into `vendor/javascript/`, rewrites every cross-package CDN
  reference (including subpath exports like `@floating-ui/utils/dom`) to a bare
  specifier, and repins each package at its local copy — so no controller loads
  from the CDN at runtime. Pass package names to vendor a subset. `wabi:add` now
  hints at it when a component needs Zag. CDN remains the default.
- **Tabs `:pill` variant.** `Tabs.new(variant: :pill)` renders a rounded
  container with a solid-primary active pill, as an alternative to the default
  `:standard` segmented look. The variant is set once on the root and propagates
  to `TabsList`/`TabsTrigger` via a `group-data-[variant=pill]` marker — no
  changes to how triggers are written, and the Stimulus controller is unchanged.

## 0.15.0 - 2026-06-03

Adds the **NumberInput** component.

### Added

- **NumberInput** — a numeric stepper input (`[ − | value | + ]`) backed by
  `@zag-js/number-input`. It hides the native browser spinner arrows and ships
  its own decrement/increment controls with full keyboard support (↑/↓,
  PageUp/PageDown, Home/End), press-and-hold to repeat, and `min`/`max`/`step`
  clamping. Supports number formatting via `Intl.NumberFormat`
  (`format: :decimal | :currency | :percent`, with `currency:` and `precision:`),
  three sizes (`:sm`/`:md`/`:lg`), optional mouse-wheel adjustment
  (`allow_mouse_wheel:`), an `invalid:` state for Form integration, and native
  form submission (the real `<input>` carries the `name`). Install with
  `bin/rails g wabi:add number_input`.

## 0.14.2 - 2026-06-02

Bugfix release. Wabi's controllers gained a real JavaScript test suite (vitest +
jsdom, the controllers exercised against the real `@zag-js` machines) — raising
JS coverage from ~18% to ~81%. That effort, plus continued live-registry
dogfooding, surfaced five real bugs, all fixed here. No API changes.

### Fixed

- **Select submitted an empty value.** The visually-hidden native `<select>` was
  rendered with no `<option>` children, so its `.value` was always `""` and the
  chosen value never reached the server on form submit. It now renders an
  `<option>` per item (plus a leading empty option so "no selection" submits
  `""`); the controller syncs the selected value as before.
- **Single-theme installs lost their styling on hydration.** The theme
  controller's `connect()` forced `data-theme="default"` (and `data-mode`) when
  `localStorage` was empty, clobbering the server-rendered value. Precedence is
  now localStorage (user choice) → server-rendered value → default.
- **Toggle's pressed state and `wabi--toggle:change` event were broken.** Zag
  calls `onPressedChange` with a bare boolean, but the controller destructured
  `{ pressed }` off it (always `undefined`). Fixed to take the boolean directly.
- **ToggleGroup leaked stale hidden inputs.** The hidden-input cleanup selector
  used the double-dash `data-wabi--toggle-group-hidden`, but the inputs were
  tagged via `dataset` (single-dash), so cleanup never matched — switching
  selection accumulated stale inputs and the form submitted stale values. Now
  tagged with `setAttribute` (matching the Slider fix).
- **`wabi:add toast` produced an unregistered controller.** `toast`'s manifest
  never declared `_shared/toast_stack.js` under `shared_files:`, so the file
  `toaster_controller.js` imports was never installed → the importmap couldn't
  pin the bare specifier → "Failed to register controller: wabi--toaster". The
  manifest now declares it; a registry spec guards every component's `_shared`
  imports against its manifest so this can't silently regress.

## 0.14.1 - 2026-06-02

Two blocking install-flow bugs surfaced by end-to-end dogfooding against the live registry.

### Fixed

- **Encoding crash on `wabi:add` / `wabi:theme`.** `Net::HTTP` tags response
  bodies `ASCII-8BIT`; writing/caching any component or theme containing a
  multibyte character (e.g. an em-dash in a comment) raised
  `Encoding::UndefinedConversionError` (BINARY→UTF-8) on Ruby 4. The registry
  client and theme generator now `force_encoding("UTF-8")` (on a dup — the body
  is frozen) before writing. This broke the happy path against the live HTTPS
  registry.
- **Zeitwerk `UI` acronym not registered.** Components install to
  `app/components/ui/` under the `Components::UI` namespace, but Zeitwerk expects
  `Components::Ui`, so a fresh app 500'd on the first component reference.
  `wabi:install` now writes `config/initializers/wabi.rb` registering
  `inflect.acronym "UI"`.

## 0.14.0 - 2026-06-02

The component registry is now live, and the gem points at it by default.

### Changed

- **Default registry URL → `https://wabi-docs.onrender.com/r`** (was the
  not-yet-wired `https://wabikit.dev/r`). The registry is now deployed (the docs
  app on Render serves `/r/*.json` for all 34 components), so
  `bin/rails g wabi:add <name>` works out of the box without
  `wabi:registry`. Override anytime with `bin/rails g wabi:registry <url>`.
  (When `wabikit.dev` is wired to the same service, the default can move back.)

## 0.13.0 - 2026-06-01

Server-driven DataTable. No breaking changes.

### Features

- **DataTable** — composes the static `Table` + `Pagination` into a server-driven
  data table. `DataTableColumnHeader` renders a sort link + asc/desc/neutral
  indicator (the Rails controller orders the query and builds the toggle href —
  no client-side data). `DataTableCheckbox` is a native, theme-styled checkbox
  (no per-row Zag machine). The `wabi--data-table` Stimulus controller
  coordinates select-all + indeterminate state, toggles each row's
  `data-state="selected"`, and dispatches `wabi--data-table:change` with the
  selected row values for app-side bulk actions. Install with
  `bin/rails g wabi:add data_table`.

## 0.12.0 - 2026-06-01

Five new components filling common shadcn gaps. No breaking changes.

### Features

- **Skeleton** — pulsing loading placeholder you size with utility classes.
- **Breadcrumb** — composable trail (`Breadcrumb`/`BreadcrumbList`/`BreadcrumbItem`/
  `BreadcrumbLink`/`BreadcrumbPage`/`BreadcrumbSeparator`/`BreadcrumbEllipsis`),
  static, no JS.
- **Pagination** — composable, link-based, server-driven
  (`Pagination`/`Content`/`Item`/`Link`/`Previous`/`Next`/`Ellipsis`); active
  link styling + `aria-current="page"`.
- **Progress** — value-driven progress bar with `role="progressbar"` semantics
  (`value:`/`max:`), static, no JS.
- **AlertDialog** — modal confirmation built on the same `@zag-js/dialog`
  machinery as Dialog, but `role="alertdialog"`, does NOT dismiss on
  click-outside, and puts initial focus on the Cancel button.

## 0.11.0 - 2026-06-01

New Table component (shadcn parity) plus a ClassMerge alignment fix.

### Features

- **Table component.** Eight composable, semantic, static primitives mirroring
  shadcn: `Table`, `TableHeader`, `TableBody`, `TableFooter`, `TableRow`,
  `TableHead`, `TableCell`, `TableCaption`. Purely presentational — no JS;
  sorting/pagination stay server-driven. Install with
  `bin/rails g wabi:add table`.

### Fixed

- **ClassMerge: `text-align` no longer collides with text color.** `text-left`,
  `text-center`, `text-right`, `text-justify`, `text-start`, and `text-end` now
  dedup in their own bucket instead of being dropped against a `text-{color}`
  utility (e.g. `text-muted-foreground`). Surfaced by `TableHead`, which needs
  both `text-left` and `text-muted-foreground` to survive.

## 0.10.0 - 2026-06-01

Toast group coordination — the last long-deferred carryover.

### Features

- **Toast Sonner-style stacking.** Toasts now collapse into a peek stack
  (`visible_count`, default 3) and expand to a full spaced list on group
  hover/focus. Overflow toasts are kept and surface as front toasts dismiss
  (their timers hold until visible). Hovering the group pauses every timer.
  `Toaster.new(visible_count:, gap:)` configure the stack. Built on a custom
  two-controller coordinator (`wabi--toaster` + `wabi--toast` via Stimulus
  outlets) — **not** `@zag-js/toast`, whose imperative DOM-creation model looped
  against Wabi's SSR + Turbo Stream append in v0.5.
- **Swipe-to-dismiss.** Drag a toast horizontally past a threshold to dismiss it.

### Breaking

- **Toast no longer bakes in a `translate-x` enter/exit transform.** The
  slide/scale is now JS-driven inline styles; the Tailwind base fades via
  opacity only. Apps that overrode the toast transform via `class:` should
  remove `translate-x-*` overrides.

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
