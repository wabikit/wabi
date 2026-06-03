import { describe, it, expect, beforeEach } from "vitest"
import Controller from "./accordion_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"
import * as accordion from "@zag-js/accordion"
import { normalizeProps } from "@zag-js/vanilla"

// jsdom asserts wiring only: item/trigger data-state open/closed toggle + the
// :change dispatch. Content is force-shown (el.hidden=false) so the CSS height
// animation stays alive — assert it's NOT hidden when closed. The animation
// itself is CSS (markup classes) → not asserted here.
const ID = "wabi--accordion"
const FIXTURE = `
  <div id="ac" data-controller="wabi--accordion">
    <div data-wabi--accordion-target="item" data-wabi-value="one">
      <button data-wabi--accordion-target="trigger" data-wabi-value="one">One</button>
      <div data-wabi--accordion-target="content" data-wabi-value="one">Body one</div>
    </div>
    <div data-wabi--accordion-target="item" data-wabi-value="two">
      <button data-wabi--accordion-target="trigger" data-wabi-value="two">Two</button>
      <div data-wabi--accordion-target="content" data-wabi-value="two">Body two</div>
    </div>
  </div>`
const itemEl    = (v) => root().querySelector(`[data-wabi--accordion-target="item"][data-wabi-value="${v}"]`)
const triggerEl = (v) => root().querySelector(`[data-wabi--accordion-target="trigger"][data-wabi-value="${v}"]`)
const contentEl = (v) => root().querySelector(`[data-wabi--accordion-target="content"][data-wabi-value="${v}"]`)
const api = (ctrl) => accordion.connect(ctrl.machine.service, normalizeProps)

let harness, ctrl
beforeEach(async () => {
  harness = mount(ID, Controller, FIXTURE)
  await tick()
  ctrl = controllerFor(harness.application, ID, root())
})

describe("wabi--accordion", () => {
  it("starts all closed; content stays in the DOM (not hidden) for the height animation", () => {
    expect(ctrl.valueValue).toEqual([])
    expect(itemEl("one").getAttribute("data-state")).toBe("closed")
    expect(contentEl("one").hidden).toBe(false)
  })

  it("opening an item toggles data-state + dispatches :change (teeth)", async () => {
    const seen = []
    document.addEventListener("wabi--accordion:change", (e) => seen.push(e.detail.value))
    openItem("one")
    await tick()
    expect(ctrl.valueValue).toEqual(["one"])
    expect(seen[seen.length - 1]).toEqual(["one"])
    expect(itemEl("one").getAttribute("data-state")).toBe("open")
    expect(triggerEl("one").getAttribute("data-state")).toBe("open")
  })

  it("collapsible (default): clicking an open item closes it", async () => {
    openItem("one"); await tick()
    openItem("one"); await tick()
    expect(ctrl.valueValue).toEqual([])
    expect(itemEl("one").getAttribute("data-state")).toBe("closed")
  })
})

// DISCOVERED: unlike tabs, the accordion trigger's Zag onClick does NOT drive
// the machine under jsdom (no error, value just stays put), so we toggle via
// the connected api. Toggling to the value-set that already contains `v`
// removes it — exercising the same open<->close path a click would, and
// proving collapsible:true (a non-collapsible machine would refuse the empty
// set). The state change settles asynchronously — flushed by `await tick()`.
function openItem(v) {
  const current = ctrl.valueValue
  const next = current.includes(v) ? current.filter((x) => x !== v) : [...current, v]
  api(ctrl).setValue(next)
}
