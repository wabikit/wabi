# Wabi — Manual Accessibility Testing Protocol

Automated tools (axe-core, see `docs/superpowers/2026-06-09-axe-audit-*`) catch ~30–40% of WCAG issues. The rest — focus management, screen-reader announcements, keyboard operability of interactive widgets — must be checked by a human. This is that checklist.

**When:** before a `1.0.0`/major release, and whenever an interactive component changes.

## Setup

- **macOS — VoiceOver:** toggle with **⌘+F5**. Navigate: **Ctrl+Option (VO) + arrows**. Open the rotor (**VO+U**) to list headings/landmarks/form-controls. Interact with a group: **VO+Shift+Down**.
- **Windows — NVDA** (free, the realistic baseline): start, then use **arrows** (browse mode) and **Tab**. Elements list: **NVDA+F7**. Toggle browse/focus mode: **NVDA+Space**.
- Test in **both light and dark mode** (the docs site defaults to dark — contrast differs).
- Test at **200% browser zoom** (WCAG 1.4.4) and with **`prefers-reduced-motion`** on (System Settings → Accessibility → Display → Reduce motion).
- Use a real keyboard only — **unplug/ignore the mouse** for the keyboard passes.

## Automated pass (axe-core) — run this first

A committed runner audits every component's docs page with axe-core (WCAG 2.0/2.1 A+AA) in real headless Chrome. It's a **regression gate**: it fails on any NEW component-level violation; known/triaged findings are allow-listed in the script (`ACCEPTED`), and docs-site chrome rules (html-lang, scrollable code blocks) are ignored.

```bash
# 1. start the docs server (any port)
cd docs && bin/rails server -p 3007 -e development &
# 2. run the audit from the registry
cd registry && BASE_URL=http://localhost:3007 pnpm run a11y
```
Env: `BASE_URL` (docs origin), `CHROME_PATH` (Chrome binary; default = macOS system Chrome). Exit 0 = clean/only-accepted; exit 1 = new finding. Script: `registry/scripts/a11y-audit.mjs`. (Not wired into CI by default — booting the docs Rails app + Chrome in CI is heavy; run it locally before releases. It only sees INITIAL state; open-overlay + the manual passes below cover the rest.)

## Universal checks (every component)

- [ ] **Tab order** is logical and matches visual order; nothing interactive is skipped or trapped (except intentional modal focus traps).
- [ ] **Focus is always visible** — a clear focus ring on every focusable element (Wabi uses `focus-visible:ring-*`).
- [ ] **No keyboard trap** (WCAG 2.1.2): you can Tab in and out of every component (modals trap intentionally — Escape must release).
- [ ] **Accessible name**: every control announces a meaningful name (not "button", "blank", "edit text").
- [ ] **State announced**: checked/expanded/selected/disabled/invalid changes are spoken.
- [ ] **Zoom 200%** + reduced-motion: no loss of content/function, no motion that ignores the preference.

## Pattern checklists

### 1. Form controls
`button, input, textarea, label, form, checkbox, switch, radio_group, select, combobox, number_input, input_otp, slider, toggle, toggle_group, tags_input, rating_group, color_picker, file_upload, date_picker, calendar`
- [ ] Each control has a name (visible `<label for>`, wrapping label, or `aria_label:`). **Wabi note:** several primitives don't self-label — the consumer must (documented per component).
- [ ] **checkbox/switch/toggle:** Space toggles; state ("checked"/"on"/"pressed") announced.
- [ ] **radio_group/toggle_group:** arrow keys move selection; group has a name (`aria_label:`); only one tab stop (roving tabindex).
- [ ] **select/combobox:** Enter/Space + arrows open and move; typeahead works; selection announced; Escape closes; combobox filters and announces result count (`aria-live`).
- [ ] **number_input:** ArrowUp/Down + PageUp/Down step; announced as a spinbutton with min/max/now; has a name.
- [ ] **slider:** arrows + Home/End + PageUp/Down; each thumb announces value/min/max; range mode names both thumbs.
- [ ] **input_otp:** typing advances slots; paste fills; the group has one name; each slot is reachable.
- [ ] **date_picker/calendar:** the grid is a `grid`; arrows move by day, PageUp/Down by month; selected/today announced; range submits both dates; the field shows the full range.
- [ ] **file_upload:** dropzone reachable by keyboard (Enter/Space opens picker); file list changes announced (`aria-live`).
- [ ] **rating_group / color_picker:** arrows change value; current value announced; color_picker channels reachable.
- [ ] **invalid state:** `invalid:` controls announce "invalid" and the error text is associated (`aria-describedby`).

### 2. Overlays
`dialog, alert_dialog, drawer, popover, hover_card, tooltip`
- [ ] Opening **moves focus into** the overlay; closing **returns focus to the trigger**.
- [ ] **Focus is trapped** while open (Tab cycles within); **Escape closes**.
- [ ] Dialog/drawer have `role=dialog`/`alertdialog` + `aria-modal`, are labelled (title) and described (body).
- [ ] Background is **inert** (not reachable by Tab or the VO cursor) while modal is open.
- [ ] **tooltip/hover_card:** reachable on **focus** (not just hover); content announced; Escape dismisses.
- [ ] **alert_dialog:** initial focus on a safe action (Cancel); no click-outside dismiss.

### 3. Menus
`dropdown_menu, context_menu, command, navigation_menu`
- [ ] Trigger opens with Enter/Space/Arrow; focus moves to the first item.
- [ ] Up/Down move; typeahead jumps; Right/Left open/close submenus; Escape closes and returns focus.
- [ ] Items announce role (`menuitem`/`menuitemcheckbox`/`menuitemradio`) + checked state.
- [ ] **context_menu:** also opens via the context-menu key / Shift+F10.
- [ ] **command:** Cmd/Ctrl+K opens; typing filters; arrows + Enter select; result count announced.

### 4. Disclosure / tabs
`accordion, collapsible, tabs`
- [ ] **accordion/collapsible:** trigger is a button with `aria-expanded`; Enter/Space toggles; expanded/collapsed announced; accordion triggers wrapped in a heading at the right `level:`.
- [ ] **tabs:** arrow keys move between tabs (roving tabindex); Enter/Space (or automatic) activates; `tab`/`tabpanel` roles; active tab announced; panel reachable.

### 5. Composite / navigation
`data_table, table, tree_view, carousel, pagination, sidebar, breadcrumb, splitter`
- [ ] **table/data_table:** real `<table>` semantics; headers associated; sortable headers announce sort state (`aria-sort`); row-select checkboxes named.
- [ ] **tree_view:** `tree`/`treeitem` roles; arrows navigate, Right/Left expand/collapse, typeahead; selection + checkbox state announced; each node named.
- [ ] **carousel:** prev/next are named buttons; slide changes announced (`aria-live` status); reachable by keyboard.
- [ ] **pagination:** `nav` + `aria-label`; current page `aria-current="page"`.
- [ ] **sidebar:** toggle named; `aria-current` on active item; collapsed-rail tooltips reachable; mobile off-canvas traps focus + inert background.
- [ ] **breadcrumb:** `nav` + ordered list; current page `aria-current="page"`.
- [ ] **splitter:** gutter is a named `separator`; arrows resize; min/max respected.

### 6. Display / feedback
`alert, badge, avatar, card, separator, skeleton, progress, toast`
- [ ] **alert/toast:** dynamically-injected ones announce via the live region (`role=alert`/`status`); toast pause-on-hover/focus; dismiss button named.
- [ ] **progress:** announces `progressbar` with now/min/max + a name.
- [ ] **skeleton:** `role=status` + `aria-busy`; doesn't spam announcements; respects reduced-motion.
- [ ] **avatar:** decorative images `alt=""`; meaningful ones have `alt`; fallback gives a name.
- [ ] **separator:** decorative ones are `role=none`/aria-hidden; semantic ones are `separator`.

## Recording results

Log each finding as: component · pattern check · AT (VoiceOver/NVDA) · severity · note. Park confirmed issues in `docs/superpowers/` and fix via the systematic-debugging + TDD flow. Re-run the axe audit after fixes (see `feedback_axe_audit` in memory for how).
