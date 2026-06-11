<p align="center">
  <img src="https://raw.githubusercontent.com/wabikit/wabi/main/docs/public/icon.png" width="84" height="84" alt="Wabi logo — a faceted gem with a chipped edge">
</p>

# Wabi

> Beautifully imperfect components for Rails.

Wabi is an open-source UI component library for **Ruby on Rails 8**, built on **Phlex + Tailwind 4 + Stimulus + Hotwire**. Inspired by shadcn/ui, components are *copied* into your app — you own the code, customize freely, no upstream API to drift away from.

🎉 **Status:** v1.0.1 — [available on RubyGems](https://rubygems.org/gems/wabi). Stable, frozen public API. 49 components, 8 theme palettes, internally audited for WCAG 2.1 AA, live docs + registry at [wabikit.dev](https://wabikit.dev).

---

## Quick start

Wabi expects a Rails 8 app with Tailwind 4 and importmap (`rails new myapp --css tailwind` gives you both).

```bash
# 1. Add the gem
bundle add wabi

# 2. Set up Phlex (skip if your app already uses phlex-rails) —
#    creates the Components::/Views:: namespaces components autoload under
bin/rails g phlex:install

# 3. Run the Wabi installer (copies tokens.css + theme controller + lockfile)
bin/rails g wabi:install

# 4. Add components from the registry
bin/rails g wabi:add button card dialog

# 5. Render — in any Phlex view or ERB template:
#   render Components::UI::Button.new(appearance: :primary) { "Click me" }
```

Then add `@import "./wabi/tokens.css";` AFTER `@import "tailwindcss";` in your `app/assets/tailwind/application.css`, and mount `data-controller="wabi--theme"` on `<html>` in your layout.

Interactive components (dialog, select, …) need their Zag.js importmap pins — `wabi:add` prints the exact `pin` lines to paste into `config/importmap.rb`. Restart the server after adding initializers or pins.

---

## What's in the box

### 49 components

| Group | Components |
|---|---|
| **Forms** (20) | Button, Input, NumberInput, Textarea, Label, Checkbox, Switch, Select, RadioGroup, Slider, Toggle, ToggleGroup, Combobox, Form, DatePicker, InputOTP, FileUpload, RatingGroup, TagsInput, ColorPicker |
| **Layout & Display** (11) | Card, Badge, Separator, Alert, Avatar, Table, DataTable, Skeleton, Sidebar, Carousel, Splitter |
| **Overlays** (7) | Dialog, AlertDialog, Drawer (4 sides), Tooltip, Popover, Command, HoverCard |
| **Menus** (2) | DropdownMenu (nested submenus, checkbox + radio items), ContextMenu |
| **Navigation** (7) | Accordion, Tabs, Breadcrumb, Pagination, Collapsible, NavigationMenu, TreeView |
| **Feedback** (2) | Toast + Toaster, Progress |

Compound components (Card, Alert, Avatar, Dialog, Drawer, Table, Form, Combobox, …) ship as composable sub-component sets. All interactive components wire through **Zag.js 1.x** state machines for WAI-ARIA roles, keyboard semantics, and focus management. Toast is the one exception: it uses a custom Stimulus coordinator for Sonner-style stacking, group pause-on-hover, and swipe-to-dismiss — `@zag-js/toast`'s imperative DOM-creation model conflicts with Wabi's SSR + Turbo Stream append.

### 8 theme palettes

`default`, `blue`, `green`, `orange`, `rose`, `stone`, `violet`, `yellow`. Light + dark variants per theme. Switch with:

```bash
bin/rails g wabi:theme rose
```

Or live-switch via the `wabi--theme` Stimulus controller (sets `data-theme` on `<html>`, persists in `localStorage`).

---

## Why Wabi

| Principle | What it means |
|---|---|
| **You own the code** | `bin/rails g wabi:add button` COPIES the Phlex source into your app. Edit, refactor, fork — there's no upstream API to drift from, because the upstream is you. |
| **Phlex-native** | Components are Ruby classes. Composition is method dispatch. Variants are class-method DSLs. Real inheritance, IDE tab-into-source, like the rest of your Rails app. |
| **Accessible by default** | Zag.js carries WAI-ARIA roles, keyboard nav, focus management, scroll lock for modals. Overlays toggle `inert` when closed so they stay out of tab order + the a11y tree. |
| **Brand-neutral** | 8 carefully-chosen palettes. None is "the Wabi look". Pick the closest one or edit HSL values directly. |
| **Hotwire-friendly** | Stimulus controllers wrap each Zag machine. `turbo_stream.wabi_toast(...)` lets the server spawn notifications without round-tripping the page. |

---

## Example: a confirmation dialog

```ruby
# app/views/users/destroy_confirmation.rb
class Views::Users::DestroyConfirmation < Views::Base
  def view_template
    render Components::UI::Dialog.new do
      render Components::UI::DialogTrigger.new(
        class: "inline-flex h-10 px-4 rounded-md bg-destructive text-destructive-foreground"
      ) { "Delete account" }

      render Components::UI::DialogContent.new do
        render Components::UI::DialogHeader.new do
          render Components::UI::DialogTitle.new       { "Delete account" }
          render Components::UI::DialogDescription.new { "This action cannot be undone." }
        end
        render Components::UI::DialogFooter.new do
          render Components::UI::DialogCancel.new { "Cancel" }
          render Components::UI::DialogAction.new(appearance: :destructive,
                                                    data: { action: "click->wabi--dialog#close" }) { "Delete" }
        end
      end
    end
  end
end
```

That's a fully-accessible modal with focus trap, scroll lock, backdrop click, Escape dismiss, and `inert` on close — out of the box. The Phlex source is in `app/components/ui/dialog*.rb`; modify whatever you want.

---

## CLI reference

| Generator | What it does |
|---|---|
| `wabi:install [--force]` | Copies `tokens.css`, the `wabi--theme` Stimulus controller, and initializes `config/wabi.lock.json`. `--force` re-copies tokens/controller on gem upgrades (lockfile is preserved). |
| `wabi:add <name…>` | Copies one or more component source files from the registry into `app/components/ui/` and their controllers into `app/javascript/controllers/wabi/`. Updates the lockfile. |
| `wabi:update <name…>` | Re-fetches installed components and 3-way merges registry changes with your local edits (conflict markers on overlap). |
| `wabi:list` | Lists all available components in the configured registry. |
| `wabi:registry <url>` | Switches the active registry origin (default: `https://wabikit.dev/r`). |
| `wabi:theme <slug>` | Swaps `tokens.css` for the requested palette. Run `bin/rails tailwindcss:build` after. |
| `wabi:vendor [pkg…]` | **Offline / strict-CSP.** Downloads the Zag `+esm` dependency graph for your jsDelivr-pinned packages into `vendor/javascript/` and repins `config/importmap.rb` at the local copies, so no controller loads from the CDN at runtime. Default: every jsDelivr `+esm` pin in the importmap. |

---

## Compatibility

- **Ruby**: 4.0 or later
- **Rails**: 8.0 or later
- **Tailwind**: 4.x (native `@theme inline`, no `tailwind.config.js`/`preset.js`)
- **Phlex**: 2.4 or later
- **Stimulus**: 3.x
- **Browsers**: Chrome 117+, Safari 17.4+, Firefox 119+ (some components use modern CSS like `grid-template-rows` height animation for Accordion)

---

## Documentation

The full docs site is live at **[wabikit.dev](https://wabikit.dev)**. To run it locally:

```bash
git clone https://github.com/wabikit/wabi
cd wabi
bin/dev      # starts registry watcher + tailwind watcher + docs server on :3000
```

Then visit:
- `/` — marketing landing
- `/docs/components` — index of all 49 components
- `/docs/components/{button,dropdown_menu,dialog,tabs}` — detailed pages with live preview + source
- `/docs/themes` — all 8 palettes side-by-side
- `/docs/getting-started`, `/docs/theming`, `/docs/philosophy` — prose docs
- `/preview` — kitchen sink (every component on one page)

---

## Monorepo layout

- `gem/` — the `wabi` Ruby gem: runtime (`Wabi::Base`, `Wabi::Variants`, `Wabi::ClassMerge`, `Wabi::RegistryClient`, `Wabi::Lockfile`) + Rails generators.
- `registry/` — component source files (`components/<name>/{manifest.yml, *.rb, *.js}`) + theme CSS files + the build pipeline emitting `dist/r/<name>.json`.
- `docs/` — the `wabikit.dev` Rails app; also serves the registry at `/r/*.json` and `/r/themes/*.css`.

---

## Working on docs

The docs site is a Rails app under `docs/`. Local dev: `bin/dev` from
repo root. The static search index lives at `docs/public/pagefind/`
and is regenerated by a Rake task that crawls every docs route via
`Rack::Test`, dumps HTML to disk, then runs `pnpm dlx pagefind` on it.

```bash
cd docs && bin/rails wabi:docs:index
```

Run this after touching any content under `docs/app/views/pages/` or
adding new component detail pages, then commit `docs/public/pagefind/`.
Requires Node 20+ in PATH (Pagefind is fetched via `npx` on demand).

---

## Roadmap

| Version | Target | Status |
|---|---|---|
| v0.1–0.3 | 20 components, 8 themes + picker, docs site + RubyGems publish | ✅ shipped 2026-05-26 |
| v0.4 | Detailed pages for all components; Pagefind search; sidebar nav | ✅ shipped 2026-05-27 |
| v0.5 | Overlays portal to `document.body`; overlay enter/exit animations | ✅ shipped 2026-05-27 |
| v0.6 | Forms expansion: RadioGroup, Toggle, ToggleGroup, Slider, Combobox, Command, Form | ✅ shipped 2026-05-28 |
| v0.7 | Quality + finish: closing v0.5/v0.6 deferrals; one breaking change | ✅ shipped 2026-05-30 |
| v0.8 | Combobox async items; a11y win + overlay-controller hardening | ✅ shipped 2026-05-31 |
| v0.9 | `wabi:update` 3-way merge; Combobox async error state; vertical Slider | ✅ shipped 2026-05-31 |
| v0.10 | Toast group coordination (Sonner-style stacking, swipe, group pause) | ✅ shipped 2026-06-01 |
| v0.11 | Table component (shadcn parity); ClassMerge text-align fix | ✅ shipped 2026-06-01 |
| v0.12 | Skeleton, Breadcrumb, Pagination, Progress, AlertDialog | ✅ shipped 2026-06-01 |
| v0.13 | DataTable (server-driven: sortable headers + row selection) | ✅ shipped 2026-06-01 |
| v0.14–0.25 | JS test suite + coverage floors; +29 components (Sidebar, Carousel, Splitter, NavigationMenu, RatingGroup, HoverCard, TagsInput, Collapsible, ColorPicker, TreeView, …); full WCAG-AA audit | ✅ shipped 2026-06-08 |
| v0.26 | API-standardization pass (frozen contract for 1.0); docs consistency sweep; automated OIDC gem releases | ✅ shipped 2026-06-09 |
| v0.30 | Pre-1.0 hardening: Turbo-cache overlay fix, Zag 1.41.2 alignment, Ruby >= 4.0 | ✅ shipped 2026-06-09 |
| **v1.0** | **Stable, frozen public API; internal WCAG 2.1 AA audit** | ✅ **shipped 2026-06-11** |
| post-1.0 | Community feedback, third-party a11y review, `wabikit.dev` | ongoing |

See [ROADMAP.md](./ROADMAP.md) for the long-term view and [CHANGELOG.md](./CHANGELOG.md) for the per-release detail.

---

## Accessibility

Wabi **targets WCAG 2.1 Level AA**. Every component has been through an internal audit: a manual screen-reader + keyboard protocol (see [`A11Y-TESTING.md`](https://github.com/wabikit/wabi/blob/main/A11Y-TESTING.md)) and an axe-core regression gate across all 49 docs pages. Interactive components inherit WAI-ARIA roles, keyboard navigation, and focus management from Zag.js; overlays toggle `inert` when closed so they leave the tab order and the a11y tree.

It has **not** had a third-party audit — so if you use assistive technology and something behaves wrong, that's the most valuable bug report Wabi can get. Open one with the [**Accessibility issue template**](https://github.com/wabikit/wabi/issues/new?template=accessibility.md) (or any issue tagged `a11y`); these are treated as priority.

---

## Contributing

The public API is stable as of 1.0 (Semantic Versioning). Issues with concrete repros, accessibility reports, component suggestions, and theme palette ideas are all welcome. See **[CONTRIBUTING.md](https://github.com/wabikit/wabi/blob/main/CONTRIBUTING.md)** for the monorepo layout, the per-component anatomy, the Zag.js wiring conventions, and how to add a component end to end.

---

## License

MIT — see [LICENSE](./LICENSE). Theme HSL values derive from [shadcn/ui](https://ui.shadcn.com)'s palettes, also MIT-licensed.
