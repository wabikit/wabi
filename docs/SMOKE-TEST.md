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

(Updated 2026-05-26 mid-Sprint-3: `class_merge` now distinguishes *atom* utilities (`flex`, `border`, `ring`, `rounded`, `outline`, `transition`, `truncate`, plus the display + position keywords) from their compound siblings — `flex flex-col` and `border border-input` both survive. It also handles axis suffixes for `translate`/`scale`/`skew`/`rotate`/`space`/`border` — `-translate-x` and `-translate-y` are independent groups. The residual cases above are the unhandled families.)

## Sprint 3 (2026-05-26)

Four overlays added: **Dialog**, **Drawer** (lateral Dialog variant — reuses `wabi--dialog` controller), **Tooltip** (hover + focus + delay), **Popover** (click). All powered by `@zag-js/*@1.41` machines through the `@zag-js/vanilla` binding. 16 components total now in the registry.

Browser-verified on `docs/` home page (`bin/dev`, Firefox):
- **Dialog** — trigger opens with backdrop + centering; Esc dismisses; click-outside dismisses; Cancel auto-closes (Zag closeTrigger); Delete uses a manual `data-action` so callers can persist before dismissing; focus trap engages inside.
- **Drawer** — all four side variants (top/right/bottom/left) anchor correctly; Esc + backdrop + Close button dismiss; reuses the Dialog controller and machine (no new JS).
- **Tooltip** — hover and focus trigger; `openDelay` (default 700ms) / `closeDelay` (default 300ms) tunable per-instance via Stimulus values; Esc dismisses while open.
- **Popover** — click trigger opens; click-outside + Esc dismiss; modal opt-in (focus trap + scroll lock); Close button via Zag closeTrigger.

### Sprint 3 patterns / traps (memo for Sprint 4+)

The three new pitfalls (now numbered 7-9 in `feedback_zag_js_pattern.md`):

7. **Stimulus Boolean data-values must serialize to `"true"`/`"false"` strings, not bare attributes.** Phlex emits `data: { foo-value: true }` as a value-less `data-foo-value`, and Stimulus's Boolean reader treats anything ≠ `"true"` as `false`. Always cast with `.to_s`. Affects every interactive component — Sprint 2 silently shipped Checkbox/Switch/Select with the bug because all demos passed `false`.

8. **Positioner needs `pointer-events-none` + an initial `hidden`, mirrored from `api.open` by the controller.** Zag emits `hidden: !open` on backdrop and content but NOT on positioner. A `fixed inset-0 z-50` positioner left visible covers the whole viewport and intercepts every click on the page — symptom: the entire UI "freezes" once the overlay's markup is on the page. Fix: (a) initial Phlex render carries `hidden: true` on the positioner; (b) Stimulus controller sets `positionerTarget.hidden = !api.open` in `render()`; (c) class includes `pointer-events-none` (content carries `pointer-events-auto`).

9. **Do NOT `document.body.appendChild(portalTarget)` in `connect()`.** Moving the portal subtree out of the Stimulus controller's scope breaks target resolution: `hasBackdropTarget`, `hasContentTarget`, etc. all return false, so the render guards short-circuit and the dialog opens internally (preventScroll fires, body locks) but nothing visible. v0.1 ships without the portal move — `position: fixed` + high z-index covers the common case. v0.2 path: capture native DOM refs to nested elements BEFORE the move, then call `spreadProps`/set `hidden` on those refs instead of through Stimulus targets.

### Sprint 3 deferrals to v0.1 polish / v0.2

- **Enter/exit animations.** Mixing `hidden: !open` with CSS transitions doesn't work — `display: none` snaps the element off-screen the instant Zag toggles hidden, so neither enter nor exit transitions complete. Tailwind 4 has no `tailwindcss-animate` equivalent installed; Sprint 3 ships with simple `transition-opacity` on Dialog (enter only) and no motion on Drawer/Tooltip/Popover. v0.2 strategy: swap `hidden` for an `inert` + class-driven approach so transitions can run before display:none kicks in.
- **Portal pattern.** Disabled in v0.1 (see trap #9). Components are still usable in the vast majority of layouts because `position: fixed` escapes normal flow; only matters when an ancestor has `transform`, `filter`, `will-change`, or `contain`, in which case fixed positioning is trapped.
- **Sprint 3 Task 1 (install tailwindcss-animate)** marked obsolete: that task's preset.js was Tailwind 3 specific and we migrated to TW4 in Sprint 0.
