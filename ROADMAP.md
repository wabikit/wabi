# Wabi Roadmap

Source of truth for shipped versions and planned scope. The README's roadmap
table mirrors this file at a glance; details live here.

## Shipped

### v0.1.0 — 2026-05-26 ✅
20 components: Button, Input, Textarea, Label, Checkbox, Switch, Select, Card,
Badge, Alert, Avatar, Separator, Dialog, Drawer, Tooltip, Popover, DropdownMenu
(+ submenus), Toast, Tabs, Accordion. Zag.js 1.x for all interactive components
except Toast (vanilla controller). WAI-ARIA roles, keyboard semantics, focus
management, `inert` toggling on overlays.

### v0.2.0 — 2026-05-26 ✅
8 theme palettes (default + slate, stone, zinc, rose, blue, green, violet) with
light + dark variants. Live theme switcher in docs nav (`Components::Site::ThemePicker`).
`/docs/themes` gallery. `bin/rails g wabi:theme <slug>` generator for user apps.
Single-source theme architecture: `registry/themes/_shared.css` + per-slug files
regenerated into gem template + docs tokens by `bin/build`.

### v0.3.0 — 2026-05-26 ✅
Real documentation site. Marketing landing at `/`. Components index at
`/docs/components` listing all 20 with manifest-derived descriptions. 4 detailed
component doc pages (Button, DropdownMenu, Dialog, Tabs) with live Preview/Code
tabs and Source listings. Prose pages: getting-started, theming, philosophy.
Kitchen-sink Sprint 1-6 home preserved at `/preview`. New shared docs components:
`Components::Site::CodeBlock` (Rouge highlight + clipboard copy), `Components::Site::ComponentPreview`
(Preview/Code tabs). Gem published to RubyGems.

## Planned

### v0.4 — docs completeness
- Detailed doc pages for the remaining 16 components (Input, Textarea, Label,
  Card, Badge, Separator, Alert, Avatar, Checkbox, Switch, Select, Drawer,
  Tooltip, Popover, Toast, Accordion).
- Pagefind static search across the docs site.
- Sidebar nav with active-section state.

### v0.5 — runtime polish
- `@zag-js/toast` group machine refactor (max stack, gap/offset, pause-on-group-hover).
- Real portal pattern for transformed-ancestor edge cases (captures native DOM refs
  before append-to-body so Stimulus target tracking survives).
- `wabi:update` generator (diff-aware, fetches latest tokens, runs `tailwindcss:build`).
- Multi-level DropdownMenu nesting (current limit: one level deep).
- `tailwind-merge`-equivalent dedup for the remaining ClassMerge edge cases
  (`bg-cover`/`bg-contain` vs `bg-{color}`, etc.).

### v0.6 — forms expansion
Forms layer matures with shadcn-comparable form primitives:
- **RadioGroup** — sibling of Checkbox/Switch.
- **Toggle** + **ToggleGroup** — single-toggle + grouped variants.
- **Slider** — Zag.js `slider.machine`.
- **Combobox** — autocomplete + listbox + popover composition.
- **Command** — keyboard-driven command palette (cmdk-style).
- **Form** — validation wiring + field/error/description composition over Rails form helpers.

### v0.7 — navigation & layout
- **Sheet** — variant of Drawer for app-shell side panels.
- **ContextMenu** — right-click variant of DropdownMenu.
- **Pagination** — page navigation primitive.
- **NavigationMenu** — mega-menu nav with hover/keyboard semantics.

### v0.8 — data, dates, ecosystem
- **Calendar** — Zag.js `date-picker` machine.
- **DatePicker** — Calendar + input + popover composition.
- **DataTable** — sortable, filterable, paginated table.
- **Blocks** — composed templates (login page, app shell, sidebar layout, dashboard cards).
- **Community registry support** — first-class hooks for third-party registries
  (`wabi:registry add <name> <url>`, multi-origin resolution in the lockfile).

### v1.0 — stability — target 2027-04
- API stability guarantee for the gem's public surface (`Wabi::Base`, `Wabi::Variants`,
  `Wabi::ClassMerge`, generator interfaces).
- External WCAG-AA accessibility audit on the full component set.
- Conference talks / launch content.

---

## Version policy

While in `0.x`, breaking changes can land in any minor version with a note in
`CHANGELOG.md`. After `1.0.0`, SemVer applies: breaking changes only on major
versions, and the deprecation cycle is at least one minor release.
