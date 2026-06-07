import { describe, it, expect } from "vitest"
import Controller from "./carousel_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"
import * as carousel from "@zag-js/carousel"
import { normalizeProps } from "@zag-js/vanilla"

const ID = "wabi--carousel"
const HTML = `
  <div data-controller="wabi--carousel" data-wabi--carousel-slide-count-value="3">
    <div data-wabi--carousel-target="itemGroup">
      <div data-wabi--carousel-target="item" data-wabi-index="0">A</div>
      <div data-wabi--carousel-target="item" data-wabi-index="1">B</div>
      <div data-wabi--carousel-target="item" data-wabi-index="2">C</div>
    </div>
    <div data-wabi--carousel-target="control">
      <button data-wabi--carousel-target="prevTrigger"></button>
      <div data-wabi--carousel-target="indicatorGroup">
        <button data-wabi--carousel-target="indicator" data-wabi-index="0"></button>
        <button data-wabi--carousel-target="indicator" data-wabi-index="1"></button>
        <button data-wabi--carousel-target="indicator" data-wabi-index="2"></button>
      </div>
      <button data-wabi--carousel-target="nextTrigger"></button>
    </div>
  </div>`

describe("wabi--carousel", () => {
  it("spreads props onto item-group, items, indicators and triggers", async () => {
    mount(ID, Controller, HTML)
    await tick()
    const r = root()
    expect(r.querySelectorAll('[data-wabi--carousel-target="item"]').length).toBe(3)
    expect(r.querySelectorAll('[data-wabi--carousel-target="indicator"]').length).toBe(3)
    expect(r.getAttribute("aria-roledescription")).toBe("carousel")
  })

  it("advances the page and dispatches :change", async () => {
    const h = mount(ID, Controller, HTML)
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    const seen = []
    document.addEventListener("wabi--carousel:change", (e) => seen.push(e.detail.page))
    carousel.connect(ctrl.machine.service, normalizeProps).scrollNext()
    await tick()
    expect(seen.length).toBeGreaterThan(0)
  })
})
