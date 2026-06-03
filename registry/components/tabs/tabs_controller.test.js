import { describe, it, expect, beforeEach } from "vitest"
import Controller from "./tabs_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"
import * as tabs from "@zag-js/tabs"
import { normalizeProps } from "@zag-js/vanilla"

// jsdom asserts wiring only: active trigger aria-selected/state, content panel
// visibility (el.hidden), and the :change dispatch.
const ID = "wabi--tabs"
const FIXTURE = `
  <div id="tb" data-controller="wabi--tabs" data-wabi--tabs-value-value="a">
    <div data-wabi--tabs-target="list">
      <button data-wabi--tabs-target="trigger" data-wabi-value="a">A</button>
      <button data-wabi--tabs-target="trigger" data-wabi-value="b">B</button>
    </div>
    <div data-wabi--tabs-target="content" data-wabi-value="a">Panel A</div>
    <div data-wabi--tabs-target="content" data-wabi-value="b">Panel B</div>
  </div>`
const trigger = (v) => root().querySelector(`[data-wabi--tabs-target="trigger"][data-wabi-value="${v}"]`)
const content = (v) => root().querySelector(`[data-wabi--tabs-target="content"][data-wabi-value="${v}"]`)
const api = (ctrl) => tabs.connect(ctrl.machine.service, normalizeProps)

let harness, ctrl
beforeEach(async () => {
  harness = mount(ID, Controller, FIXTURE)
  await tick()
  ctrl = controllerFor(harness.application, ID, root())
})

describe("wabi--tabs", () => {
  it("starts on the default tab: A selected + panel A visible, B hidden", () => {
    expect(ctrl.valueValue).toBe("a")
    expect(trigger("a").getAttribute("aria-selected")).toBe("true")
    expect(trigger("b").getAttribute("aria-selected")).toBe("false")
    expect(content("a").hidden).toBe(false)
    expect(content("b").hidden).toBe(true)
  })

  it("activating tab B switches selection + panel visibility, dispatches :change (teeth)", async () => {
    const seen = []
    document.addEventListener("wabi--tabs:change", (e) => seen.push(e.detail.value))
    selectTab("b")
    await tick()
    expect(ctrl.valueValue).toBe("b")
    expect(seen).toEqual(["b"])
    expect(trigger("b").getAttribute("aria-selected")).toBe("true")
    expect(content("b").hidden).toBe(false)
    expect(content("a").hidden).toBe(true)
  })
})

// DISCOVERED: the trigger is a real <button> carrying Zag's getTriggerProps
// onClick, so a native .click() drives the machine (the change settles
// asynchronously — flushed by the test's `await tick()`).
function selectTab(v) {
  trigger(v).click()
}
