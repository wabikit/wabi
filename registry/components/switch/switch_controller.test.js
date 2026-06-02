import { describe, it, expect, beforeEach } from "vitest"
import Controller from "./switch_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"

// jsdom asserts wiring only: data-state, hidden <input> .checked mirror, :change.
const ID = "wabi--switch"
const FIXTURE = `
  <button id="sw" type="button" data-controller="wabi--switch" data-wabi--switch-name-value="notify">
    <span data-wabi--switch-target="control"><span data-wabi--switch-target="thumb"></span></span>
    <input type="checkbox" data-wabi--switch-target="hiddenInput">
  </button>`
const hidden  = () => root().querySelector('[data-wabi--switch-target="hiddenInput"]')

let harness, ctrl
beforeEach(async () => {
  harness = mount(ID, Controller, FIXTURE)
  await tick()
  ctrl = controllerFor(harness.application, ID, root())
})

describe("wabi--switch", () => {
  it("starts off: hidden input unchecked", () => {
    expect(ctrl.checkedValue).toBe(false)
    expect(hidden().checked).toBe(false)
  })

  it("clicking turns it on: state + hidden input + :change (teeth)", async () => {
    const seen = []
    document.addEventListener("wabi--switch:change", (e) => seen.push(e.detail.checked))
    // Zag drives the switch off the real hidden <input>; the control span is a
    // non-interactive visual element (clicking it does not toggle in jsdom).
    hidden().click()
    await tick()
    expect(ctrl.checkedValue).toBe(true)
    expect(hidden().checked).toBe(true)
    expect(root().getAttribute("data-state")).toBe("checked")
    expect(seen).toContain(true)
  })

  it("hidden input carries the form name", () => {
    expect(hidden().getAttribute("name")).toBe("notify")
  })
})
