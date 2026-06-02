import { describe, it, expect, beforeEach } from "vitest"
import Controller from "./popover_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, byTarget, root } from "../../test/support/overlay.js"

// Popover is non-modal by default → it does NOT register with WabiPortalRegistry.
// It has no public open()/close(); state is driven by the trigger handler Zag
// wires via getTriggerProps(). jsdom asserts wiring only — NOT positioning /
// focus-trap / scroll-lock.
const ID = "wabi--popover"

// (ResizeObserver no-op for popper positioning is polyfilled globally in
// test/support/setup.js — popover/tooltip/select/dropdown_menu all need it.)

const FIXTURE = `
  <div id="pop" data-controller="wabi--popover">
    <button data-wabi--popover-target="trigger">Open</button>
    <div data-wabi--popover-target="positioner">
      <div data-wabi--popover-target="content">
        <button data-wabi--popover-target="closeTrigger">Close</button>
      </div>
    </div>
  </div>`

let harness, ctrl
beforeEach(async () => {
  harness = mount(ID, Controller, FIXTURE)
  await tick()
  ctrl = controllerFor(harness.application, ID, root())
})

describe("wabi--popover", () => {
  it("portals content to <body> and captures the ref", () => {
    const content = byTarget(ID, "content")
    expect(content.closest("#pop")).toBeNull()
    expect(ctrl.contentEl).toBe(content)
  })

  it("starts closed: data-state=closed and isOpen() false", () => {
    const content = byTarget(ID, "content")
    expect(ctrl.isOpen()).toBe(false)
    expect(content.getAttribute("data-state")).toBe("closed")
  })

  it("clicking the trigger opens it (data-state=open, inert cleared)", async () => {
    byTarget(ID, "trigger").click()
    await tick()
    const content = byTarget(ID, "content")
    expect(content.getAttribute("data-state")).toBe("open")
    expect(content.hasAttribute("inert")).toBe(false)
    expect(ctrl.isOpen()).toBe(true)
  })

  it("decorates trigger with aria-controls pointing at the content id", () => {
    const trigger = byTarget(ID, "trigger")
    const content = byTarget(ID, "content")
    expect(content.id).toBeTruthy()
    expect(trigger.getAttribute("aria-controls")).toBe(content.id)
  })

  it("dispatches wabi--popover:change on open then close (teeth)", async () => {
    const seen = []
    // Popover is non-modal (no focus-trap), so the close :change dispatch is
    // faithfully testable in jsdom — this is the canonical close-dispatch teeth
    // for the overlay family (the modal dialog/alert_dialog can't assert it).
    document.addEventListener("wabi--popover:change", (e) => seen.push(e.detail.open))
    byTarget(ID, "trigger").click(); await tick()
    byTarget(ID, "closeTrigger").click(); await tick()
    expect(seen).toEqual([true, false])
  })
})
