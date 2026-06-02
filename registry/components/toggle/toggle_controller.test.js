import { describe, it, expect, beforeEach } from "vitest"
import Controller from "./toggle_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"

// Toggle is a pressed-state button with NO hidden input — assert aria-pressed +
// the :change dispatch. The root <button> itself carries Zag's onClick.
// jsdom asserts wiring only.
const ID = "wabi--toggle"
const FIXTURE = `<button id="tg" data-controller="wabi--toggle">Bold</button>`

let harness, ctrl
beforeEach(async () => {
  harness = mount(ID, Controller, FIXTURE)
  await tick()
  ctrl = controllerFor(harness.application, ID, root())
})

describe("wabi--toggle", () => {
  it("starts unpressed", () => {
    expect(ctrl.pressedValue).toBe(false)
    expect(root().getAttribute("aria-pressed")).toBe("false")
  })

  it("clicking toggles pressed and dispatches :change (teeth)", async () => {
    const seen = []
    document.addEventListener("wabi--toggle:change", (e) => seen.push(e.detail.pressed))
    root().click()
    await tick()
    expect(ctrl.pressedValue).toBe(true)
    expect(root().getAttribute("aria-pressed")).toBe("true")
    expect(seen).toEqual([true])
  })
})
