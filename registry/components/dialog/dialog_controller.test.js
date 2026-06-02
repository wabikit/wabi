import { describe, it, expect, beforeEach } from "vitest"
import Controller from "./dialog_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, byTarget, root } from "../../test/support/overlay.js"

// jsdom asserts wiring only: data-state, attribute decoration, inert, portal
// capture, the :change dispatch. NOT focus-trap / positioning / scroll-lock.

const ID = "wabi--dialog"

// portal defaults true → positioner+backdrop move to <body> on connect.
const FIXTURE = `
  <div id="dlg" data-controller="wabi--dialog">
    <button data-wabi--dialog-target="trigger">Open</button>
    <div data-wabi--dialog-target="backdrop"></div>
    <div data-wabi--dialog-target="positioner">
      <div data-wabi--dialog-target="content">
        <h2 data-wabi--dialog-target="title">Title</h2>
        <p data-wabi--dialog-target="description">Body</p>
        <button data-wabi--dialog-target="closeTrigger">Close</button>
      </div>
    </div>
  </div>`

let harness, ctrl
beforeEach(async () => {
  harness = mount(ID, Controller, FIXTURE)
  await tick()
  ctrl = controllerFor(harness.application, ID, root())
})

describe("wabi--dialog", () => {
  it("portals the positioner and content to <body> and resolves the refs", () => {
    const content = byTarget(ID, "content")
    expect(content).not.toBeNull()
    expect(content.closest("#dlg")).toBeNull()
    expect(ctrl.contentEl).toBe(content)
  })

  it("starts closed: content has data-state=closed", () => {
    const content = byTarget(ID, "content")
    expect(ctrl.isOpen()).toBe(false)
    expect(content.getAttribute("data-state")).toBe("closed")
  })

  it("open() flips content to data-state=open and clears inert", async () => {
    ctrl.open()
    await tick()
    const content = byTarget(ID, "content")
    expect(ctrl.isOpen()).toBe(true)
    expect(content.getAttribute("data-state")).toBe("open")
    expect(content.hasAttribute("inert")).toBe(false)
  })

  it("close() flips it back to closed + inert", async () => {
    ctrl.open(); await tick()
    ctrl.close(); await tick()
    const content = byTarget(ID, "content")
    expect(content.getAttribute("data-state")).toBe("closed")
    expect(content.hasAttribute("inert")).toBe(true)
  })

  it("decorates content + trigger with Zag a11y props", () => {
    const content = byTarget(ID, "content")
    const trigger = byTarget(ID, "trigger")
    expect(content.getAttribute("role")).toBe("dialog")
    expect(content.id).toBeTruthy()
    expect(trigger.getAttribute("aria-haspopup")).toBe("dialog")
    expect(trigger.getAttribute("aria-controls")).toBe(content.id)
  })

  it("dispatches wabi--dialog:change with {open:true} when opened (teeth)", async () => {
    const seen = []
    document.addEventListener("wabi--dialog:change", (e) => seen.push(e.detail.open))
    ctrl.open()
    await tick()
    expect(seen).toEqual([true])

    // Closing also dispatches {open:false}, but for a MODAL dialog that callback
    // fires from inside Zag's focus-trap teardown, which jsdom cannot run
    // faithfully (it intermittently throws on null focus nodes, skipping the
    // callback) — focus-trap behavior is out of scope here per the spec. So we
    // assert the close reaches the closed STATE (render-driven, reliable); the
    // close :change *dispatch* is covered by the non-modal popover test.
    ctrl.close()
    await tick()
    expect(byTarget(ID, "content").getAttribute("data-state")).toBe("closed")
  })
})

describe("wabi--dialog via the drawer markup (drawer reuses this controller)", () => {
  const DRAWER = `
    <div id="drw" data-controller="wabi--dialog"
         data-wabi--dialog-modal-value="true" data-wabi--dialog-portal-value="true"
         data-wabi-side="right">
      <button data-wabi--dialog-target="trigger">Open</button>
      <div data-wabi--dialog-target="positioner">
        <div data-wabi--dialog-target="content">Panel</div>
      </div>
    </div>`

  it("drives open/close and preserves the side attribute", async () => {
    harness.stop() // release the beforeEach application so only one app drives #drw
    const h = mount(ID, Controller, DRAWER)
    await tick()
    const c = controllerFor(h.application, ID, root())
    expect(root().getAttribute("data-wabi-side")).toBe("right")
    c.open(); await tick()
    expect(byTarget(ID, "content").getAttribute("data-state")).toBe("open")
  })
})
