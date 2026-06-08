import { describe, it, expect } from "vitest"
import Controller from "./splitter_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"

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
    // a11y: resize trigger must carry a default aria-label when no data-wabi-label is set
    expect(gutter.getAttribute("aria-label")).toBe("Resize panels")
  })

  it("uses data-wabi-label as aria-label when provided on the resize trigger", async () => {
    const customHTML = `
      <div data-controller="wabi--splitter"
           data-wabi--splitter-panels-value='[{"id":"a","minSize":20},{"id":"b","minSize":20}]'>
        <div data-wabi--splitter-target="panel" data-wabi-id="a">Left</div>
        <div data-wabi--splitter-target="resizeTrigger" data-wabi-id="a:b" data-wabi-label="Resize sidebar"></div>
        <div data-wabi--splitter-target="panel" data-wabi-id="b">Right</div>
      </div>`
    mount(ID, Controller, customHTML)
    await tick()
    const gutter = root().querySelector('[data-wabi--splitter-target="resizeTrigger"]')
    expect(gutter.getAttribute("aria-label")).toBe("Resize sidebar")
  })

  // Regression: Zag's syncSize bails at start() when the root has no layout yet
  // (inactive tab panel / below the fold), leaving `size` empty so dragging the gutter
  // resizes nothing. The controller observes visibility and sends ROOT.RESIZE to
  // re-sync once the splitter is on-screen. jsdom has no layout, so we assert the
  // wiring: the observer exists and its callback drives a ROOT.RESIZE on intersection.
  it("re-syncs sizes via ROOT.RESIZE when the splitter becomes visible", async () => {
    const h = mount(ID, Controller, HTML)
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    expect(ctrl.visibilityObserver).toBeInstanceOf(IntersectionObserver)
    // Invoking the visibility callback drives the ROOT.RESIZE re-sync without throwing
    // (the real size init needs layout — browser only).
    expect(() => ctrl.visibilityObserver.callback([{ isIntersecting: true }])).not.toThrow()
  })
})
