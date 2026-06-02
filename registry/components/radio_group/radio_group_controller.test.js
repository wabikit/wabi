import { describe, it, expect, beforeEach } from "vitest"
import Controller from "./radio_group_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"

// jsdom asserts wiring only: selected item data-state, the per-item hidden
// radio input .checked mirror, and the :change dispatch.
const ID = "wabi--radio-group"
const item = (v) => `
  <label data-wabi--radio-group-target="item" data-wabi-value="${v}">
    <span data-wabi--radio-group-target="itemControl" data-wabi-value="${v}">
      <span data-wabi--radio-group-target="itemIndicator"></span>
    </span>
    <span data-wabi--radio-group-target="itemText" data-wabi-value="${v}">${v}</span>
    <input type="radio" data-wabi--radio-group-target="hiddenInput" data-wabi-value="${v}">
  </label>`
const FIXTURE = `
  <div id="rg" data-controller="wabi--radio-group" data-wabi--radio-group-name-value="plan">
    ${item("free")}${item("pro")}
  </div>`

const itemEl    = (v) => root().querySelector(`[data-wabi--radio-group-target="item"][data-wabi-value="${v}"]`)
const hiddenEl  = (v) => root().querySelector(`[data-wabi--radio-group-target="hiddenInput"][data-wabi-value="${v}"]`)

let harness, ctrl
beforeEach(async () => {
  harness = mount(ID, Controller, FIXTURE)
  await tick()
  ctrl = controllerFor(harness.application, ID, root())
})

describe("wabi--radio-group", () => {
  it("hidden inputs carry the shared form name", () => {
    expect(hiddenEl("free").getAttribute("name")).toBe("plan")
    expect(hiddenEl("pro").getAttribute("name")).toBe("plan")
  })

  it("selecting an item sets its state, checks its hidden input, dispatches :change (teeth)", async () => {
    const seen = []
    document.addEventListener("wabi--radio-group:change", (e) => seen.push(e.detail.value))
    selectItem("pro")  // the per-item hidden radio input is the interactive el in jsdom
    await tick()
    expect(ctrl.valueValue).toBe("pro")
    expect(seen).toEqual(["pro"])
    expect(itemEl("pro").getAttribute("data-state")).toBe("checked")
    expect(hiddenEl("pro").checked).toBe(true)
    expect(hiddenEl("free").checked).toBe(false)
  })
})

function selectItem(v) {
  hiddenEl(v).click()
}
