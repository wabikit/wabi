# Wabi

> Beautifully imperfect components for Rails.

Wabi is an open-source UI component library for **Ruby on Rails 8**, built on **Phlex + Tailwind 4 + Stimulus + Hotwire**. Inspired by shadcn/ui, components are *copied* into your app — you own the code, customize freely, no upstream API to drift away from.

🎉 **Status:** v0.22.0 alpha — [available on RubyGems](https://rubygems.org/gems/wabi). 40 components, 8 theme palettes, WCAG-AA targeted, live docs + registry at [wabi-docs.onrender.com](https://wabi-docs.onrender.com).

---

## Quick start

```bash
# 1. Add the gem
bundle add wabi

# 2. Run the installer (copies tokens.css + theme controller + lockfile)
bin/rails g wabi:install

# 3. Add components from the registry
bin/rails g wabi:add button card dialog

# 4. Render
# In any Phlex view:
#   render Components::UI::Button.new(appearance: :primary) { "Click me" }
```

Then add `@import "./wabi/tokens.css";` AFTER `@import "tailwindcss";` in your `app/assets/tailwind/application.css`, and mount `data-controller="wabi--theme"` on `<html>` in your layout.

---

## What's in the box

### 36 components

| Group | Components |
|---|---|
| **Forms** (14) | Button, Input, NumberInput, Textarea, Label, Checkbox, Switch, Select, RadioGroup, Slider, Toggle, ToggleGroup, Combobox, Form |
| **Layout & Display** (9) | Card, Badge, Separator, Alert, Avatar, Table, DataTable, Skeleton, Sidebar |
| **Overlays** (6) | Dialog, AlertDialog, Drawer (4 sides), Tooltip, Popover, Command |
| **Menus** (1) | DropdownMenu (nested submenus, checkbox + radio items) |
| **Navigation** (4) | Accordion, Tabs, Breadcrumb, Pagination |
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
| `wabi:list` | Lists all available components in the configured registry. |
| `wabi:registry <url>` | Switches the active registry origin (default: `https://wabi-docs.onrender.com/r`). |
| `wabi:theme <slug>` | Swaps `tokens.css` for the requested palette. Run `bin/rails tailwindcss:build` after. |
| `wabi:vendor [pkg…]` | **Offline / strict-CSP.** Downloads the Zag `+esm` dependency graph for your jsDelivr-pinned packages into `vendor/javascript/` and repins `config/importmap.rb` at the local copies, so no controller loads from the CDN at runtime. Default: every jsDelivr `+esm` pin in the importmap. |

---

## Compatibility

- **Ruby**: 3.4 or later
- **Rails**: 8.0 or later
- **Tailwind**: 4.x (native `@theme inline`, no `tailwind.config.js`/`preset.js`)
- **Phlex**: 2.4 or later
- **Stimulus**: 3.x
- **Browsers**: Chrome 117+, Safari 17.4+, Firefox 119+ (some components use modern CSS like `grid-template-rows` height animation for Accordion)

---

## Documentation

The full docs site is at the GitHub repo's `docs/` Rails app (also planned to host at https://wabikit.dev when DNS is wired). Locally:

```bash
git clone https://github.com/wabikit/wabi
cd wabi
bin/dev      # starts registry watcher + tailwind watcher + docs server on :3000
```

Then visit:
- `/` — marketing landing
- `/docs/components` — index of all 36 components
- `/docs/components/{button,dropdown_menu,dialog,tabs}` — detailed pages with live preview + source
- `/docs/themes` — all 8 palettes side-by-side
- `/docs/getting-started`, `/docs/theming`, `/docs/philosophy` — prose docs
- `/preview` — the Sprint 1-6 kitchen sink (every component on one page)

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
`Rack::Test`, dumps HTML to disk, then runs `npx pagefind` on it.

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
| v1.0 | API stability; external a11y audit | 2027-04 target |

See [ROADMAP.md](./ROADMAP.md) for the long-term view and [CHANGELOG.md](./CHANGELOG.md) for the per-release detail.

---

## Contributing

Wabi is in alpha and the API is still moving. Filing issues with concrete repros, suggestions for components, or theme palette ideas is the most useful kind of contribution right now. A `CONTRIBUTING.md` documenting the per-component anatomy and the Zag.js wiring conventions is still on the to-do list.

---

## License

MIT — see [LICENSE](./LICENSE). Theme HSL values derive from [shadcn/ui](https://ui.shadcn.com)'s palettes, also MIT-licensed.
