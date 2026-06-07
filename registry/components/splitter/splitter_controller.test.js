import { describe, it, expect } from "vitest"
import Controller from "./splitter_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { root } from "../../test/support/overlay.js"

const ID = "wabi--splitter"
const HTML = `
  <div data-controller="wabi--splitter"
       data-wabi--splitter-panels-value='[{"id":"a","minSize":20},{"id":"b","minSize":20}]'>
    <div data-wabi--splitter-target="panel" data-wabi-id="a">Left</div>
    <div data-wabi--splitter-target="resizeTrigger" data-wabi-id="a:b"></div>
    <div data-wabi--splitter-target="panel" data-wabi-id="b">Right</div>
  </div>`

describe("wabi--splitter", () => {
  it("spreads root + panel + resize-trigger props", async () => {
    mount(ID, Controller, HTML)
    await tick()
    const r = root()
    // Zag v1.41 sets data-orientation on root (no role="group" in this version)
    expect(r.getAttribute("data-orientation")).toBe("horizontal")
    const panels = r.querySelectorAll('[data-wabi--splitter-target="panel"]')
    expect(panels.length).toBe(2)
    const gutter = r.querySelector('[data-wabi--splitter-target="resizeTrigger"]')
    expect(gutter.getAttribute("role")).toBe("separator")
  })
})
