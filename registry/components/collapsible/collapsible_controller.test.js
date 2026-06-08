import { describe, it, expect } from "vitest"
import Controller from "./collapsible_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"
import * as collapsible from "@zag-js/collapsible"
import { normalizeProps } from "@zag-js/vanilla"

// jsdom has no layout engine, so trigger.click() does not propagate into the Zag
// machine's internal onClick handler. We drive state changes via the connected API
// (api.setOpen), which is the same code path the machine uses internally.
const ID = "wabi--collapsible"
const api = (ctrl) => collapsible.connect(ctrl.machine.service, normalizeProps)
const HTML = (attrs = "") => `
  <div id="col" data-controller="wabi--collapsible" ${attrs}>
    <button data-wabi--collapsible-target="trigger">Toggle</button>
    <div data-wabi--collapsible-target="content" data-state="closed"><div>Body</div></div>
  </div>`

describe("wabi--collapsible", () => {
  it("starts closed and opens via api.setOpen", async () => {
    const h = mount(ID, Controller, HTML())
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    const content = root().querySelector('[data-wabi--collapsible-target="content"]')
    expect(content.getAttribute("data-state")).toBe("closed")
    expect(content.hidden).toBe(false)
    api(ctrl).setOpen(true)
    await tick()
    expect(content.getAttribute("data-state")).toBe("open")
  })

  // Regression: once open + settled, Zag's getContentProps sets data-state to
  // undefined (skip = !initial && open) — the grid-rows animation needs it to
  // PERSIST as "open". The controller re-asserts it from api.open on every render.
  // We force the skip condition by flipping the machine's `initial` context to false.
  it("keeps content data-state=open after Zag drops it (skip case)", async () => {
    const h = mount(ID, Controller, HTML())
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    const content = root().querySelector('[data-wabi--collapsible-target="content"]')
    api(ctrl).setOpen(true)
    await tick()
    expect(content.getAttribute("data-state")).toBe("open")
    // Simulate the post-measurement render where Zag would null data-state.
    ctrl.machine.service.context.set("initial", false)
    ctrl.render()
    expect(content.getAttribute("data-state")).toBe("open")
  })

  it("dispatches :change with the open state", async () => {
    const h = mount(ID, Controller, HTML())
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    const seen = []
    document.addEventListener("wabi--collapsible:change", (e) => seen.push(e.detail.open))
    api(ctrl).setOpen(true)
    await tick()
    expect(seen[seen.length - 1]).toBe(true)
  })
})
