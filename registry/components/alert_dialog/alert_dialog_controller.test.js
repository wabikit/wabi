import { describe, it, expect, beforeEach } from "vitest"
import Controller from "./alert_dialog_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, byTarget, root } from "../../test/support/overlay.js"

// alert_dialog shares Zag's dialog machine but adds closeOnInteractOutside:false
// and initialFocusEl → the Cancel button. The controller does NOT pass an
// alertdialog role option to the machine, so Zag emits role="dialog" on the
// content (the alertdialog distinction lives in config/markup, not the role
// attribute — see discovery note below). Focus behavior is NOT faithfully
// testable in jsdom; we assert config intent (the controller captures cancelEl)
// + the emitted role + state wiring. jsdom asserts wiring only — NOT focus-trap
// / positioning / scroll-lock.
const ID = "wabi--alert-dialog"

const FIXTURE = `
  <div id="ad" data-controller="wabi--alert-dialog">
    <button data-wabi--alert-dialog-target="trigger">Delete</button>
    <div data-wabi--alert-dialog-target="positioner">
      <div data-wabi--alert-dialog-target="content">
        <h2 data-wabi--alert-dialog-target="title">Sure?</h2>
        <p data-wabi--alert-dialog-target="description">No undo.</p>
        <button data-wabi--alert-dialog-target="cancel closeTrigger">Cancel</button>
        <button data-wabi--alert-dialog-target="closeTrigger">Confirm</button>
      </div>
    </div>
  </div>`

let harness, ctrl
beforeEach(async () => {
  harness = mount(ID, Controller, FIXTURE)
  await tick()
  ctrl = controllerFor(harness.application, ID, root())
})

describe("wabi--alert-dialog", () => {
  it("captures the cancel element for initialFocusEl (config intent)", () => {
    expect(ctrl.cancelEl).not.toBeNull()
    expect(ctrl.cancelEl.textContent).toContain("Cancel")
  })

  it("content carries the dialog role (alertdialog distinction is config, not role)", () => {
    // The controller doesn't request an alertdialog role from the Zag machine,
    // so Zag decorates content with role="dialog". The alert-dialog semantics
    // come from closeOnInteractOutside:false + initialFocusEl, not this attr.
    expect(byTarget(ID, "content").getAttribute("role")).toBe("dialog")
    expect(byTarget(ID, "content").id).toBeTruthy()
  })

  it("starts closed; open() → data-state=open + inert cleared; close() → closed + inert", async () => {
    const content = byTarget(ID, "content")
    expect(content.getAttribute("data-state")).toBe("closed")
    ctrl.open(); await tick()
    expect(content.getAttribute("data-state")).toBe("open")
    expect(content.hasAttribute("inert")).toBe(false)
    ctrl.close(); await tick()
    expect(content.getAttribute("data-state")).toBe("closed")
    expect(content.hasAttribute("inert")).toBe(true)
  })

  it("dispatches wabi--alert-dialog:change with {open} (teeth)", async () => {
    const seen = []
    document.addEventListener("wabi--alert-dialog:change", (e) => seen.push(e.detail.open))
    ctrl.open(); await tick()
    ctrl.close(); await tick()
    expect(seen).toEqual([true, false])
  })
})
