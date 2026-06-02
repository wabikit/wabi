import { describe, it, expect, beforeEach } from "vitest"
import Controller from "./checkbox_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"

// jsdom asserts wiring only: data-state, the hidden <input> .checked mirror,
// and the :change dispatch. Not visual indicator geometry.
const ID = "wabi--checkbox"
const FIXTURE = `
  <span id="cb" data-controller="wabi--checkbox"
        data-wabi--checkbox-name-value="agree" data-wabi--checkbox-value-value="yes">
    <span data-wabi--checkbox-target="control">
      <span data-wabi--checkbox-target="indicator">✓</span>
    </span>
    <input type="checkbox" data-wabi--checkbox-target="hiddenInput">
  </span>`
const hidden  = () => root().querySelector('[data-wabi--checkbox-target="hiddenInput"]')

let harness, ctrl
beforeEach(async () => {
  harness = mount(ID, Controller, FIXTURE)
  await tick()
  ctrl = controllerFor(harness.application, ID, root())
})

describe("wabi--checkbox", () => {
  it("starts unchecked: root data-state + hidden input reflect it", () => {
    expect(ctrl.checkedValue).toBe(false)
    expect(hidden().checked).toBe(false)
    expect(root().getAttribute("data-state")).toBe("unchecked")
  })

  it("clicking checks it: state flips, hidden input mirrors, :change fires (teeth)", async () => {
    const seen = []
    document.addEventListener("wabi--checkbox:change", (e) => seen.push(e.detail.checked))
    // Zag drives the checkbox off the real hidden <input>; the control span is
    // a non-interactive visual element (clicking it does not toggle in jsdom).
    hidden().click()
    await tick()
    expect(ctrl.checkedValue).toBe(true)
    expect(hidden().checked).toBe(true)
    expect(root().getAttribute("data-state")).toBe("checked")
    expect(seen).toContain(true)
  })

  it("the hidden input carries the form name + value", () => {
    expect(hidden().getAttribute("name")).toBe("agree")
    expect(hidden().getAttribute("value")).toBe("yes")
  })
})
