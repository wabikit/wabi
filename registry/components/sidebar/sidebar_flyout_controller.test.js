import { describe, it, expect, beforeEach, afterEach } from "vitest"
import Controller from "./sidebar_flyout_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"

const ID = "wabi--sidebar-flyout"

function setViewport(desktop) {
  window.matchMedia = (q) => ({ matches: desktop, media: q, addEventListener() {}, removeEventListener() {}, addListener() {}, removeListener() {}, onchange: null, dispatchEvent: () => false })
}
function stubRect(rect) {
  Element.prototype.getBoundingClientRect = () => ({ top: 0, left: 0, right: 0, bottom: 0, width: 0, height: 0, x: 0, y: 0, ...rect })
}

function mountFlyout({ state = "collapsed", closeDelay = 0 } = {}) {
  const FIXTURE = `
    <div data-controller="wabi--sidebar" data-state="${state}">
      <details data-controller="wabi--sidebar-flyout" data-wabi--sidebar-flyout-close-delay-value="${closeDelay}">
        <summary>Projects</summary>
        <ul data-flyout="closed"><li><a href="#">Apollo</a></li></ul>
      </details>
    </div>`
  return mount(ID, Controller, FIXTURE)
}
const details = () => root().querySelector("details")
const summary = () => root().querySelector("summary")
const panel   = () => root().querySelector("ul")
const ctrlOf  = (h) => controllerFor(h.application, ID, details())

const origRect = Element.prototype.getBoundingClientRect
beforeEach(() => { stubRect({ top: 100, left: 8, right: 60, bottom: 132 }) })
afterEach(() => { Element.prototype.getBoundingClientRect = origRect })

describe("wabi--sidebar-flyout", () => {
  it("opens the flyout on trigger hover when collapsed + desktop", async () => {
    setViewport(true)
    const h = mountFlyout()
    await tick()
    summary().dispatchEvent(new MouseEvent("mouseenter"))
    expect(panel().dataset.flyout).toBe("open")
    expect(panel().style.left).not.toBe("")
    expect(panel().style.top).toBe("100px")
  })

  it("does nothing when expanded", async () => {
    setViewport(true)
    const h = mountFlyout({ state: "expanded" })
    await tick()
    summary().dispatchEvent(new MouseEvent("mouseenter"))
    expect(panel().dataset.flyout).toBe("closed")
  })

  it("does nothing on mobile", async () => {
    setViewport(false)
    const h = mountFlyout()
    await tick()
    summary().dispatchEvent(new MouseEvent("mouseenter"))
    expect(panel().dataset.flyout).toBe("closed")
  })

  it("stays open moving from trigger to panel, closes after leaving both", async () => {
    setViewport(true)
    const h = mountFlyout({ closeDelay: 0 })
    await tick()
    summary().dispatchEvent(new MouseEvent("mouseenter"))
    summary().dispatchEvent(new MouseEvent("mouseleave"))
    panel().dispatchEvent(new MouseEvent("mouseenter"))
    await tick()
    expect(panel().dataset.flyout).toBe("open")
    panel().dispatchEvent(new MouseEvent("mouseleave"))
    await tick()
    expect(panel().dataset.flyout).toBe("closed")
  })

  it("Escape closes the flyout", async () => {
    setViewport(true)
    const h = mountFlyout()
    await tick()
    summary().dispatchEvent(new MouseEvent("mouseenter"))
    document.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape" }))
    expect(panel().dataset.flyout).toBe("closed")
  })

  it("auto-flips to the left near the right viewport edge", async () => {
    setViewport(true)
    stubRect({ top: 100, left: window.innerWidth - 20, right: window.innerWidth - 10, bottom: 132 })
    const h = mountFlyout()
    await tick()
    summary().dispatchEvent(new MouseEvent("mouseenter"))
    expect(parseInt(panel().style.left, 10)).toBeLessThan(window.innerWidth - 20)
  })
})
