import { describe, it, expect, beforeEach } from "vitest"
import Controller from "./toggle_group_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"

// jsdom asserts wiring only: the dynamically-created hidden <input>s mirroring
// the selected value(s) + the :change dispatch. Items are <button>s carrying
// Zag's getItemProps onClick.
const ID = "wabi--toggle-group"
const FIXTURE = `
  <div id="tgrp" data-controller="wabi--toggle-group"
       data-wabi--toggle-group-name-value="align"
       data-wabi--toggle-group-multiple-value="false">
    <button data-wabi--toggle-group-target="item" data-wabi-value="left">L</button>
    <button data-wabi--toggle-group-target="item" data-wabi-value="center">C</button>
  </div>`
const itemEl  = (v) => root().querySelector(`[data-wabi--toggle-group-target="item"][data-wabi-value="${v}"]`)
const hiddens = () => [...root().querySelectorAll(':scope > input[type="hidden"][data-wabi--toggle-group-hidden="true"]')]

let harness, ctrl
beforeEach(async () => {
  harness = mount(ID, Controller, FIXTURE)
  await tick()
  ctrl = controllerFor(harness.application, ID, root())
})

describe("wabi--toggle-group", () => {
  it("selecting an item updates value, creates one hidden input, dispatches :change (teeth)", async () => {
    const seen = []
    document.addEventListener("wabi--toggle-group:change", (e) => seen.push(e.detail.value))
    itemEl("center").click()
    await tick()
    expect(ctrl.valueValue).toEqual(["center"])
    expect(seen[seen.length - 1]).toEqual(["center"])
    const h = hiddens()
    expect(h.length).toBe(1)            // single mode → exactly one input, no stale leak
    expect(h[0].name).toBe("align")     // single mode → bare name (no [])
    expect(h[0].value).toBe("center")
  })

  it("switching selection replaces the hidden input (no stale accumulation)", async () => {
    itemEl("center").click()
    await tick()
    itemEl("left").click()
    await tick()
    const h = hiddens()
    expect(h.length).toBe(1)            // the double-dash cleanup selector now matches → no leak
    expect(h[0].value).toBe("left")
  })
})
