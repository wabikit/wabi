# End-to-end smoke test

Procedure (last run: 2026-05-25, Sprint 0):

1. Boot registry + docs: `cd registry && mise exec -- bundle exec bin/build; cd ../docs && mise exec -- bin/dev`
2. Generate fresh Rails app: `mise exec -- rails new /tmp/wabi-smoke --css=tailwind --javascript=importmap`
3. Add wabi path-dep + phlex-rails to Gemfile, run `bundle install`
4. `bin/rails g phlex:install`
5. Register `UI` acronym in `config/initializers/inflections.rb`
6. `bin/rails g wabi:install`
7. `bin/rails g wabi:registry http://localhost:3000/r`
8. `bin/rails g wabi:add button`
9. Wrap generated button in `module Components` for Phlex 2.x autoload
10. Append `@import "./wabi/tokens.css";` to `app/assets/tailwind/application.css`
11. Render `Components::UI::Button` in a Phlex view, with `stylesheet_link_tag("tailwind", "data-turbo-track": "reload")`
12. Boot smoke app on port 4000, verify in browser: Button shows with primary color, large size

## Sprint 1 (2026-05-25)

All 9 components (Button + 8 statics: Input, Textarea, Label, Card, Badge, Separator, Alert, Avatar) installable via single `wabi:add button input textarea label card badge separator alert avatar` command. 18 .rb files generated in `app/components/ui/` (single-file: button/input/textarea/label/badge/separator; compounds: card+5, alert+2, avatar+2). Lockfile shows 9 component entries.

Tailwind 4 tokens `bg-card`, `text-card-foreground`, `bg-popover`, `text-popover-foreground` extended via `@theme inline` in `tokens.css`; resolve correctly in both default and dark mode.

Kitchen-sink page renders all components with correct styling. Compounds (Card, Alert, Avatar) compose their sub-components. Phlex 2.x autoload resolves `Components::UI::*` for all generated files (registry sources now ship pre-wrapped per the Sprint 0 carry-over fix).

## Sprint 2 (2026-05-26)

Three interactive components added: **Checkbox**, **Switch**, **Select** (compound). All powered by `@zag-js/*@1.41` state machines + a Stimulus controller per component, with the framework-agnostic `@zag-js/vanilla` binding (`VanillaMachine`, `normalizeProps`, `spreadProps`).

Browser-verified on `docs/` home page (`bin/dev`, Firefox):
- **Checkbox** — click toggles `data-state` on the visual control + `bg-primary`; checkmark indicator appears/disappears; hidden `<input type=checkbox>` carries `name=value` for form submission; Space key toggles when focused.
- **Switch** — click flips `data-state` on track + thumb, thumb slides via `data-[state=checked]:translate-x-5`; Space key toggles.
- **Select** — trigger opens popover; arrow keys + typeahead navigate items; Enter/click selects; `valueText` updates to selected label; Escape closes; hidden native `<select>` mirrors the selection for form submission.

### Sprint 2 patterns / traps (memo for Sprint 3+)

The original plan was written against Zag.js `^0.50` prose mixed with React-binding examples. Adapting to Zag.js 1.x cost a full debugging cycle. Conventions now locked in for the rest of the roadmap (see `feedback_zag_js_pattern.md` in agent memory):

1. **Importmap pin = jsdelivr `+esm`**, not `bin/importmap pin`. The latter only downloads each package's `dist/index.mjs` and leaves sibling submodule files (`*.machine.mjs`, `*.connect.mjs`, etc.) unresolved → 404 on hydration → controller silently fails to connect.
2. **`normalizeProps` + `spreadProps` + `VanillaMachine` all live in `@zag-js/vanilla`** (Zag 1.x), not in `@zag-js/dom-query`.
3. **Construction is `new VanillaMachine(machine, props)` + `connect(service, normalizeProps)` (2-arg)**, not the old `machine.machine({...})` + `connect(state, send, normalize)` (3-arg).
4. **Markup follows Zag's anatomy**: root `<label>` (or `<div>` for popovers) + real native input (`<input type=checkbox>` for Checkbox/Switch, `<select>` for Select) with `class="sr-only"` for form submission + keyboard, visible control as a sibling styled via `data-[state=...]` attributes.
5. **Initial state uses `defaultX`, not `X`** (`defaultChecked`, `defaultValue`, `defaultOpen`). Passing the controlled prop makes the bindable refuse internal updates — symptoms: "clicks do nothing", "selection doesn't update label".
6. **Popover `hidden` belongs on the content div, not on the positioner wrapper** — Zag emits `hidden: !open` on `getContentProps`, and a hidden positioner cascades `display:none` so nothing inside ever becomes visible.

### Sprint 2 gem-side fix

`Wabi::ClassMerge` was silently dropping every variant-prefixed Tailwind utility. The naive `token.split("-").first` group key collapsed `data-[state=checked]:bg-primary`, `data-[state=checked]:text-X`, and every `focus-visible:ring-*` under the same bucket — so the *last* utility in a chain was the only one to survive. `group_key` is now variant-aware (`focus-visible:`, `data-[...]:`, etc. preserved in the key, with `:` correctly scoped past `[...]` arbitrary values). Four new specs lock in the variant-scoped behavior. Affects every component, not just Sprint 2 — Sprint 1 components silently regressed before and now render with their full intended class set.

### Known residual class_merge edge cases (v0.1 carryover)

Within a single variant scope, utilities that share a prefix but represent different CSS properties still collide. Examples:
- `border` (border-width) vs `border-primary` (border-color) → both group under `border`, color wins.
- `ring-2` vs `ring-ring` vs `ring-offset-2` → all group under `focus-visible:ring`, offset wins.

Components keep working (the visible cues are driven by `data-state` attributes, not by these utilities), but the focus ring is weaker than designed and the checkbox/select-trigger borders are color-only with no width. Full tailwind-merge-equivalent dedup is a post-v0.1 task.
