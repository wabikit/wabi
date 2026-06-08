import { describe, it, expect, beforeEach } from "vitest"
import Controller from "./alert_dialog_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, byTarget, root } from "../../test/support/overlay.js"

// alert_dialog shares Zag's dialog machine but adds closeOnInteractOutside:false,
// initialFocusEl → the Cancel button, and role:"alertdialog" (so Zag emits
// role="alertdialog" on the content and the controller overrides the trigger's
// aria-haspopup to "alertdialog"). Focus behavior is NOT faithfully testable in
// jsdom; we assert config intent (the controller captures cancelEl) + the emitted
// role + state wiring. jsdom asserts wiring only — NOT focus-trap / positioning.
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

  it("content carries role=alertdialog and the trigger advertises aria-haspopup=alertdialog", () => {
    // The controller passes role:"alertdialog" to the machine, so Zag decorates
    // the content with role="alertdialog"; the trigger's aria-haspopup is
    // corrected to match (Zag hardcodes "dialog" there).
    expect(byTarget(ID, "content").getAttribute("role")).toBe("alertdialog")
    expect(byTarget(ID, "content").id).toBeTruthy()
    expect(byTarget(ID, "trigger").getAttribute("aria-haspopup")).toBe("alertdialog")
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

  it("dispatches wabi--alert-dialog:change with {open:true} when opened (teeth)", async () => {
    const seen = []
    document.addEventListener("wabi--alert-dialog:change", (e) => seen.push(e.detail.open))
    ctrl.open()
    await tick()
    expect(seen).toEqual([true])

    // Like dialog, the modal close dispatch rides Zag's focus-trap teardown,
    // which jsdom can't run faithfully (out of scope per the spec). Assert the
    // close reaches the closed STATE; the close :change dispatch is covered by
    // the non-modal popover test.
    ctrl.close()
    await tick()
    expect(byTarget(ID, "content").getAttribute("data-state")).toBe("closed")
  })
})
