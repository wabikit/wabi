# Contributing to Wabi

Thanks for your interest in Wabi! Wabi is **beautifully imperfect components for
Rails** — Phlex + Tailwind 4 + Stimulus + Hotwire, inspired by shadcn/ui:
components are *copied* into your app, so you own the code.

Wabi is in **alpha** and the API is still moving. The most useful contributions
right now:

- **Issues with concrete repros** — the fastest way to get something fixed.
- **New components** — toward shadcn parity (see [ROADMAP.md](ROADMAP.md)).
- **Theme palettes** and accessibility fixes.
- **Docs** corrections and examples.

This document covers how the monorepo is laid out, the per-component anatomy,
the Zag.js wiring conventions, and how to add a component end to end.

---

## Monorepo layout

```
wabi/
├── gem/        # the published `wabi` gem: Wabi::Base, the variants DSL,
│               # ClassMerge, generators (wabi:install / wabi:add / wabi:theme)
├── registry/   # SOURCE OF TRUTH for components + the registry builder
│   └── components/<name>/   # {manifest.yml, <name>.rb (+ parts), <name>_controller.js, spec.rb, *_controller.test.js}
└── docs/       # the Rails docs app (wabi-docs.onrender.com), which renders
                # BYTE-IDENTICAL COPIES of every component under app/components/ui/
```

`registry/components/` is canonical. The docs app keeps a byte-identical copy of
each component's `.rb` parts (in `docs/app/components/ui/`) and controller (in
`docs/app/javascript/controllers/wabi/`). See [docs ↔ registry](#docs--registry-parity).

### Environment

Ruby is managed by [mise](https://mise.jdx.dev/). **Prefix every Ruby/Node command
with `mise exec --`** so it runs under the pinned toolchain:

```bash
cd registry && mise exec -- bundle install        # registry Ruby deps
cd registry && mise exec -- yarn install           # registry JS deps (Zag, vitest)
cd docs     && mise exec -- bundle install          # docs app
```

Run the docs app with **`bin/dev`** (or at least `bin/rails tailwindcss:build`),
**never bare `rails server`** — otherwise the gitignored compiled
`docs/app/assets/builds/tailwind.css` is stale and new utility classes render
unstyled.

```bash
cd docs && mise exec -- bin/dev      # → http://localhost:3000
```

---

## Anatomy of a component

Every component is a [Phlex](https://www.phlex.fun) view that subclasses
`Wabi::Base` inside `Components::UI`. `Wabi::Base` is just `Phlex::HTML` with the
variants DSL extended in and a private `merge_class` helper:

```ruby
# gem/lib/wabi/base.rb
module Wabi
  class Base < Phlex::HTML
    extend Wabi::Variants
    private

    def merge_class(*classes) = Wabi::ClassMerge.call(*classes)
  end
end
```

### The variants DSL

For components with visual variants, declare them with the CVA-style DSL and
resolve them with `tokens(...)`:

```ruby
# frozen_string_literal: true

module Components
  module UI
    class Button < Wabi::Base
      variants do
        base "inline-flex items-center justify-center rounded-md text-sm font-medium " \
             "transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring " \
             "disabled:pointer-events-none disabled:opacity-50"

        variant :appearance, {
          primary:     "bg-primary text-primary-foreground hover:bg-primary/90",
          secondary:   "bg-secondary text-secondary-foreground hover:bg-secondary/80",
          destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
          outline:     "border border-primary bg-background text-primary hover:bg-accent",
          ghost:       "hover:bg-accent hover:text-accent-foreground",
          link:        "text-primary underline-offset-4 hover:underline"
        }, default: :primary

        variant :size, { sm: "h-9 px-3", md: "h-10 px-4 py-2", lg: "h-11 px-8", icon: "h-10 w-10" }, default: :md
      end

      def initialize(appearance: nil, size: nil, **attrs)
        @appearance = appearance
        @size       = size
        @attrs      = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(
          **@attrs,
          class: merge_class(tokens(appearance: @appearance, size: @size), user_class),
          &block
        )
      end
    end
  end
end
```

### The conventions every part follows

1. **`# frozen_string_literal: true`** at the top. If the component builds a
   `data: {}` hash, also `require "date"` immediately after — Phlex 2.4 references
   `Date`/`Time` constants lazily while rendering `data:` hashes, and the require
   keeps load order sane.
2. Module `Components::UI`, class `< Wabi::Base`.
3. Collect unrecognized attributes in `**attrs`, store as `@attrs`.
4. In `view_template`, **always** pull the caller's class out first and merge it
   last so user classes win:
   ```ruby
   user_class = @attrs.delete(:class)
   div(class: merge_class(BASE_OR_TOKENS, user_class)) { ... }
   ```
5. `merge_class` (= `Wabi::ClassMerge`) dedupes conflicting Tailwind utilities
   (the later/user class wins), so callers can override styling cleanly.
6. **Compound components** ship as a set of small parts (e.g. `Card`,
   `CardHeader`, `CardTitle`, `CardContent`) — one focused file per part, each a
   `Components::UI::*` class.

---

## Interactive components: the Zag.js pattern

All interactive components wire through **[Zag.js](https://zagjs.com) 1.x** state
machines via a Stimulus controller. **Toast is the one exception** — it uses a
custom Sonner-style coordinator because `@zag-js/toast`'s imperative
DOM-creation model fights SSR + Turbo Streams.

The Phlex part renders static DOM tagged with `data-controller="wabi--<name>"`
and `data-wabi--<name>-target="..."`; the controller mounts the machine and
spreads Zag's prop getters onto those targets on every render:

```javascript
import { Controller } from "@hotwired/stimulus"
import * as colorPicker from "@zag-js/color-picker"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["trigger", "content", /* … */]
  static values  = { value: { type: String, default: "#000000" } }

  connect() {
    this.machine = new VanillaMachine(colorPicker.machine, {
      id: this.element.id || crypto.randomUUID(),
      // …config from data-*-value attributes…
      onValueChange: ({ valueAsString }) => this.dispatch("change", { detail: { value: valueAsString } }),
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.render()
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
  }

  render() {
    const api = colorPicker.connect(this.machine.service, normalizeProps)
    if (this.hasTriggerTarget) spreadProps(this.triggerTarget, api.getTriggerProps())
    if (this.hasContentTarget) spreadProps(this.contentTarget, api.getContentProps())
    // …spread the rest…
  }
}
```

- Mirror Zag versions: install each machine at the same `1.41.x` your importmap
  pins (see `docs/config/importmap.rb`).
- **Overlays portal to `<body>`** via `controllers/wabi/_shared/overlay_portal.js`
  (`capturePortalRefs` / `attachToBody` / `restoreFromBody`). Capture the content
  ref BEFORE moving it, and query in-content parts via `this.contentEl.querySelectorAll(...)`
  — Stimulus `*Targets` stop resolving once the node leaves the controller's subtree.
  Declare the shared file in the manifest's `shared_files:`.

### ⚠️ Gotcha: Zag getter `style` clobbers your Tailwind

Zag prop getters often return their **own inline `style`** (e.g.
`getItemProps` → `style { --depth }`, `getAreaBackgroundProps` →
`style { position: relative }`). `spreadProps` writes that style attribute,
which **overrides your Tailwind classes** (inline beats class) and can replace
the whole `style` attribute.

**Rule:** never rely on Tailwind `absolute`/`inset-0`/positioning or inline
CSS-vars on an element you `spreadProps` a Zag getter onto. Size/position it with
properties Zag does *not* set (e.g. `h-full w-full`), or put your custom styling
on a **child wrapper** the controller never touches. (This has bitten us three
times — area spectrum collapsing to height 0, tree-view leaf indentation
disappearing, value-text rendering empty.)

---

## Adding a component end to end

1. **Create `registry/components/<name>/`** with:
   - `<name>.rb` (+ one file per sub-part for compound components)
   - `<name>_controller.js` (if interactive)
   - `manifest.yml` (see below)
   - `spec.rb` (RSpec) and `<name>_controller.test.js` (Vitest, if interactive)
2. **Write tests first** (TDD) — a failing `spec.rb`, then the parts; a failing
   `*_controller.test.js`, then the controller.
3. **Mirror to docs** — copy the parts to `docs/app/components/ui/<name>*.rb` and
   the controller to `docs/app/javascript/controllers/wabi/<name>_controller.js`,
   byte-identical (`diff` must be empty).
4. **Register in the docs app:**
   - add `<name>` to the `ALL` array in `docs/app/controllers/components_controller.rb`
   - add it to the right group in `docs/app/components/site/sidebar.rb`
   - pin any new Zag deps in `docs/config/importmap.rb`
   - add `/docs/components/<name>` to `docs/spec/requests/docs_smoke_spec.rb`
   - create the page `docs/app/views/pages/components/<name>.rb`
5. **Rebuild the registry dist:**
   ```bash
   cd registry && mise exec -- bundle exec ./bin/build   # regenerates dist/r/*.json (+ tokens.css)
   ```
6. **Verify interactive behavior in a real browser** (see [Testing](#testing)).

### `manifest.yml`

```yaml
name: color_picker
version: 0.1.0
type: registry:ui            # registry:ui | registry:form
description: One-line summary shown in the docs index.
registry_dependencies: []    # other Wabi components this one needs
ruby_dependencies: []
js_dependencies:             # Zag packages this component imports
  "@zag-js/color-picker": "^1.41"
  "@zag-js/vanilla": "^1.41"
shared_files:                # files pulled from registry/components/_shared/
  - "_shared/overlay_portal.js"
tailwind:
  extend: {}
metadata:
  a11y: WCAG-AA
  rails_min: "8.0"
  phlex_min: "1.11"
```

The builder embeds every `.rb`/`.js` file as a content string in `dist/r/<name>.json`;
`*_controller.test.js` is excluded from the shipped dist.

---

## Testing

| Layer | Command (from `registry/`) | Covers |
|---|---|---|
| **RSpec** | `mise exec -- bundle exec rspec components/<name>/spec.rb` | rendered HTML, targets, data attrs |
| **Vitest** | `mise exec -- yarn test components/<name>/<name>_controller.test.js` | controller wiring (state, events, DOM decoration) |
| **Docs smoke** (from `docs/`) | `mise exec -- bundle exec rspec spec/requests/docs_smoke_spec.rb` | every component page returns 200 |

- **Coverage floors are enforced.** Vitest has `coverage.thresholds` in
  `registry/vitest.config.js`; RSpec has `SimpleCov.minimum_coverage` in both
  spec_helpers. Don't drop below them. The single-component RSpec run also has a
  ~55% branch floor, so cover both the block and no-block paths of any part that
  `yield`s.
- **jsdom can't do layout, focus, or floating-ui positioning.** Vitest verifies
  *logic and wiring* (state transitions, `data-state`, `aria-*`, `role`, `inert`,
  dispatched events, portal moves) — not pixels or real focus.
- **Verify interactive components in real headless Chrome.** Several browser-only
  bugs (carousel snap, splitter sizing, collapsible state, the Zag-`style`
  clobbering above) cannot be caught by jsdom. Drive the running docs page over
  CDP (`--headless=new --remote-debugging-port`, attach to a **page** target via
  `Target.createTarget` + `Target.attachToTarget {flatten:true}`) and assert the
  **actual visual property in question** (computed padding/height, gradient
  present, bounding box, focus moves) — not merely "the element exists".

---

## docs ↔ registry parity

Every component `.rb` and controller `.js` lives in **both**
`registry/components/<name>/` (source of truth) and the docs app
(`docs/app/components/ui/` + `docs/app/javascript/controllers/wabi/`). The copies
must be **byte-identical**:

```bash
diff registry/components/<name>/<name>.rb docs/app/components/ui/<name>.rb       # must be empty
diff registry/components/<name>/<name>_controller.js docs/app/javascript/controllers/wabi/<name>_controller.js
```

After editing a component, re-copy to docs and confirm the `diff` is clean.

---

## Pull requests

- `main` is branch-protected — open a PR from a feature branch.
- Keep the suites green: RSpec + Vitest + docs smoke, and `bin/build` so
  `dist/r/*.json` is regenerated.
- Keep docs ↔ registry copies in sync in the same PR.
- Match the existing commit style (conventional prefixes: `feat(x): …`,
  `fix(x): …`, `docs(x): …`, `chore: …`). One logical change per commit.
- For a new interactive component, include a note on how you verified it in a
  real browser.

---

## Operational gotchas (don't relearn these)

- **`bin/dev`, not `rails server`** — bare server serves stale Tailwind.
- **Rebuild the registry dist** (`bin/build`) after adding/changing a component;
  CI (`registry-build.yml`) verifies every component has dist.
- **`docs/Gemfile.lock` + `registry/Gemfile.lock` are committed** (Render needs
  them, `x86_64-linux` platform). After bumping the gem version, run
  `cd docs && bundle install` or Render's frozen bundler rejects the old version
  (path-gem drift).
- **`gem push` / RubyGems / Render CLI need network + auth** that the sandbox
  blocks — run those with the sandbox disabled.
- **Toast is the one non-Zag interactive component** (custom coordinator); don't
  try to route it through a Zag machine.

Happy hacking. When in doubt, copy the closest existing component and follow its
shape.
