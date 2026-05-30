# v0.6 Carryover — closed 2026-05-28

All seven Forms components landed. v0.6.0 was tagged on 2026-05-28.
See [CHANGELOG.md](../CHANGELOG.md) for the full release entry.

## Closed in v0.6

- **Forms wave**: 7 new components (Toggle, RadioGroup, ToggleGroup,
  Slider, Combobox, Form, Command) — 26 sub-components in total.
- **Combobox uses the Sprint 9 portal pattern** as a non-modal anchored
  overlay — first new component to consume the abstraction; confirms it
  holds.
- **Two-controller composition trick** (Command): both `wabi--dialog`
  and `wabi--command` initialize on the same root element. The combobox
  controller is mounted on an inner wrapper so its
  `spreadProps(getRootProps())` doesn't strip `role`/`aria-modal`/
  `data-state` from the dialog content.
- **Docs polish**: sidebar scroll preservation, active link styling via
  `aria-[current=page]:`, Pagefind indexer rebased on
  `ComponentsController::ALL`, multi-field Form demo with client-side
  validation.

## Carried over from v0.5 (still deferred)

- **Toast `@zag-js/toast` group machine** — v0.5 attempt reverted; v0.6
  did not retry (Forms-only sprint).
- **Toast Sonner-style enter/exit animations** — paired with the group
  machine retry.
- **Overlay controller boilerplate refactor** — the now-six overlay
  controllers (Dialog, Drawer, Popover, Tooltip, DropdownMenu, Select,
  Combobox) share `attachToBody`/`restoreFromBody`/captured-refs
  boilerplate. A shared mixin or base class could deduplicate.
- **Vestigial `wabi--<name>-target="portal"` wrappers** in
  `*_content.rb` — still in place to keep the DOM stable when
  `portal: false`.
- **DropdownMenu multi-level submenu nesting** (sub-inside-sub) — still
  single-level only.
- **`wabi:update` three-way merge** — current v0.5 prompts on conflict.
- **Phlex 2.4 Ruby 4 warnings** — still waiting on upstream.

## New deferrals from v0.6

- **Combobox async items** — v0.6 supports only static `items:` arrays.
  Adding server-side fetching (via Turbo Frame, callback URL, or a
  fetch-on-input pattern) is planned for v0.7.
- **Combobox `ComboboxItemIndicator` wiring** — the subcomponent is
  exported but the controller's `render()` doesn't loop over
  `itemIndicatorTargets`. Either wire it (mirror Select's pattern) or
  drop the export.
- **Combobox `disabled:` on individual items** —
  `data-wabi-disabled="true"` is written to the `<li>` but the
  collection passed to Zag doesn't include an `isItemDisabled` callback,
  so the Tailwind `data-[disabled]:*` variants never trigger. Fix
  requires accepting `disabled` as an item-array key and forwarding it
  to `combobox.collection({ items, isItemDisabled })`.
- **Slider marks/ticks** — visual markers at specific track positions.
  Uncommon use case; deferred.
- ~~**Slider hidden-input naming for range mode** — currently emits
  `name_min` / `name_max`. Whether to switch to Rails-native
  `name[min]` / `name[max]` is an open question; once shipped, changing
  it is breaking.~~ ✅ **Resolved in v0.7** — switched to `name[min]` /
  `name[max]` (breaking). See CHANGELOG 0.7.0.
- ~~**Command palette item selection** — the `wabi--command` bridge
  listens on the Command root for `wabi--combobox:change`, but the
  dialog portal moves the combobox under `<body>`, so the bubbling
  event never reaches the bridge.~~ ✅ **Resolved in v0.7** — took fix
  path (a): document-level event delegation with id-linkage filtering.
  See V07-CARRYOVER.

## Known limits documented in v0.6

- **Slider hidden-input name convention** for range mode: `<name>_min`
  and `<name>_max`. Apps using Rails strong params must permit both.
- **Combobox empty state**: standalone Combobox shows nothing when the
  filter yields zero items. Use Command's `CommandEmpty` pattern (or
  build your own) if you need an explicit empty-state message.
- **Combobox form submission**: the visible `<input>` carries the
  selected item's LABEL (Zag's default). A sibling
  `<input type="hidden" name="...">` is rendered inside the Combobox
  root and the controller mirrors the value into it, so form
  submissions post the value, not the label.
- **Form's `helpers.form_with`** assumes Phlex 2.x with the Rails
  helper chain available. Apps with non-standard view bases may need
  to override the Form component's `view_template`. The component
  includes `Phlex::Rails::Helpers::FormWith` guarded with `if defined?`
  so the registry spec (which lacks `phlex-rails`) still loads.
- **Toggle vs Switch**: Toggle = button-style press (toolbar-friendly).
  Switch = sliding control (settings-friendly). Docs page for Toggle
  states this prominently.
- **Command is preview in v0.6**: the docs page ships an explicit
  amber callout naming the two outstanding wiring carry-overs.
