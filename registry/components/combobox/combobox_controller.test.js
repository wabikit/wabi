import { describe, it, expect, beforeEach } from "vitest"
import Controller from "./combobox_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, byTarget, root } from "../../test/support/overlay.js"
import * as combobox from "@zag-js/combobox"
import { normalizeProps } from "@zag-js/vanilla"

// Combobox is a NON-modal portal+popper overlay (ResizeObserver polyfilled in
// setup.js). jsdom asserts wiring only: open/close state + inert, the value
// mirror into the hidden <input>, collection-from-DOM, and :change. NOT
// floating-ui positioning.
const ID = "wabi--combobox"
const api = (ctrl) => combobox.connect(ctrl.machine.service, normalizeProps)

// items-value EMPTY → collection built from the rendered DOM <li> items.
const FIXTURE = `
  <div id="cbx" data-controller="wabi--combobox"
       data-wabi--combobox-name-value="lang" data-wabi--combobox-items-value="[]">
    <label data-wabi--combobox-target="label">Lang</label>
    <div data-wabi--combobox-target="control">
      <input data-wabi--combobox-target="input">
      <button data-wabi--combobox-target="trigger">▼</button>
    </div>
    <input type="hidden" data-wabi--combobox-target="hiddenInput">
    <div data-wabi--combobox-target="positioner">
      <ul data-wabi--combobox-target="content">
        <div aria-live="polite" aria-atomic="true" data-wabi--combobox-target="loading" class="sr-only px-2 py-1.5 text-sm text-muted-foreground">Loading…</div>
        <div aria-live="polite" aria-atomic="true" data-wabi--combobox-target="error" class="sr-only px-2 py-1.5 text-sm text-destructive">Error</div>
        <li data-wabi--combobox-target="item" data-wabi-value="rb" data-wabi-label="Ruby">Ruby</li>
        <li data-wabi--combobox-target="item" data-wabi-value="js" data-wabi-label="JS">JS</li>
      </ul>
    </div>
  </div>`

const hidden = () => root().querySelector('[data-wabi--combobox-target="hiddenInput"]')

let harness, ctrl
beforeEach(async () => {
  harness = mount(ID, Controller, FIXTURE)
  await tick()
  ctrl = controllerFor(harness.application, ID, root())
})

describe("wabi--combobox", () => {
  it("builds the collection from DOM items when items-value is empty", () => {
    expect(ctrl.items.map((i) => i.value)).toEqual(["rb", "js"])
    expect(byTarget(ID, "content").closest("#cbx")).toBeNull()  // portaled to <body>
  })

  it("open() shows content (data-state open, inert cleared); close() reverses it", async () => {
    ctrl.open(); await tick()
    const content = byTarget(ID, "content")
    expect(content.getAttribute("data-state")).toBe("open")
    expect(content.hasAttribute("inert")).toBe(false)
    ctrl.close(); await tick()
    expect(content.getAttribute("data-state")).toBe("closed")
    expect(content.hasAttribute("inert")).toBe(true)
  })

  it("selecting a value mirrors it into the hidden input + dispatches :change (teeth)", async () => {
    const seen = []
    document.addEventListener("wabi--combobox:change", (e) => seen.push(e.detail.value))
    api(ctrl).setValue(["js"])
    await tick()
    expect(ctrl.valueValue).toBe("js")
    expect(hidden().value).toBe("js")
    expect(seen).toEqual(["js"])
  })

  // WCAG live-region fix: showLoading/showError toggle `sr-only` CSS class
  // instead of the `hidden` attribute so the aria-live region stays in the
  // accessibility tree at all times, enabling screen-reader announcements.
  // The loading/error elements live inside contentEl which is portaled to body,
  // so we query document (not root()) to find them.
  it("showLoading(true) removes sr-only from loading el; showLoading(false) restores it", async () => {
    const loadingEl = document.querySelector('[data-wabi--combobox-target="loading"]')
    // starts visually hidden
    expect(loadingEl.classList.contains("sr-only")).toBe(true)
    expect(loadingEl.hasAttribute("hidden")).toBe(false)

    ctrl.showLoading(true)
    expect(loadingEl.classList.contains("sr-only")).toBe(false)
    expect(loadingEl.hasAttribute("hidden")).toBe(false)

    ctrl.showLoading(false)
    expect(loadingEl.classList.contains("sr-only")).toBe(true)
    expect(loadingEl.hasAttribute("hidden")).toBe(false)
  })

  it("showError(true) removes sr-only from error el; showError(false) restores it", async () => {
    const errorEl = document.querySelector('[data-wabi--combobox-target="error"]')
    // starts visually hidden
    expect(errorEl.classList.contains("sr-only")).toBe(true)
    expect(errorEl.hasAttribute("hidden")).toBe(false)

    ctrl.showError(true)
    expect(errorEl.classList.contains("sr-only")).toBe(false)
    expect(errorEl.hasAttribute("hidden")).toBe(false)

    ctrl.showError(false)
    expect(errorEl.classList.contains("sr-only")).toBe(true)
    expect(errorEl.hasAttribute("hidden")).toBe(false)
  })
})
