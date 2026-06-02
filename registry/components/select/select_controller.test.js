import { describe, it, expect, beforeEach } from "vitest"
import * as select from "@zag-js/select"
import { normalizeProps } from "@zag-js/vanilla"
import Controller from "./select_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, byTarget, root } from "../../test/support/overlay.js"

// Select builds a Zag collection from items-value, mirrors the chosen value into
// a hidden <select>, and dispatches wabi--select:change. We assert the value/
// label mirror + the dispatch. Listbox positioning is NOT asserted.
// jsdom asserts wiring only — NOT positioning / focus / scroll-lock.
const ID = "wabi--select"

const FIXTURE = `
  <div id="sel" data-controller="wabi--select"
       data-wabi--select-name-value="fruit"
       data-wabi--select-items-value='[{"value":"a","label":"Apple"},{"value":"b","label":"Banana"}]'>
    <button data-wabi--select-target="trigger">
      <span data-wabi--select-target="valueText"></span>
      <span data-wabi--select-target="indicator"></span>
    </button>
    <select data-wabi--select-target="hiddenSelect">
      <option value="" selected>Select an option</option>
      <option value="a">Apple</option>
      <option value="b">Banana</option>
    </select>
    <div data-wabi--select-target="positioner">
      <div data-wabi--select-target="content">
        <ul data-wabi--select-target="list">
          <li data-wabi--select-target="item" data-wabi-value="a">
            <span data-wabi--select-target="itemText">Apple</span>
            <span data-wabi--select-target="itemIndicator"></span>
          </li>
          <li data-wabi--select-target="item" data-wabi-value="b">
            <span data-wabi--select-target="itemText">Banana</span>
            <span data-wabi--select-target="itemIndicator"></span>
          </li>
        </ul>
      </div>
    </div>
  </div>`

let harness, ctrl
beforeEach(async () => {
  harness = mount(ID, Controller, FIXTURE)
  await tick()
  ctrl = controllerFor(harness.application, ID, root())
})

describe("wabi--select", () => {
  it("portals content + captures item refs", () => {
    const content = byTarget(ID, "content")
    expect(content.closest("#sel")).toBeNull()
    expect(ctrl.itemEls.length).toBe(2)
  })

  it("shows the placeholder before any selection", () => {
    expect(byTarget(ID, "valueText").textContent).toBe("Select an option")
  })

  it("selecting an item updates valueText, the hidden select, and dispatches :change", async () => {
    const seen = []
    document.addEventListener("wabi--select:change", (e) => seen.push(e.detail.value))
    selectValue(ctrl, "b")
    await tick()
    expect(byTarget(ID, "valueText").textContent).toBe("Banana")
    expect(seen).toEqual(["b"])
    expect(byTarget(ID, "hiddenSelect").value).toBe("b")
  })

  it("root + trigger carry Zag listbox decoration (teeth)", () => {
    expect(byTarget(ID, "content").id).toBeTruthy()
    expect(byTarget(ID, "trigger").getAttribute("aria-controls")).toBeTruthy()
  })
})

// Discovered mechanism: see report. The connected api drives selection.
function selectValue(ctrl, value) {
  const api = select.connect(ctrl.machine.service, normalizeProps)
  api.selectValue(value)
}
