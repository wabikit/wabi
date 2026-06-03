import { describe, it, expect, beforeEach, afterEach } from "vitest"
import Controller from "./sidebar_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"

const ID = "wabi--sidebar"

function setViewport(desktop) {
  window.matchMedia = (q) => ({
    matches: desktop, media: q,
    addEventListener() {}, removeEventListener() {},
    addListener() {}, removeListener() {}, onchange: null, dispatchEvent: () => false,
  })
}

function mountSidebar(attrs = "") {
  const FIXTURE = `
    <div data-controller="wabi--sidebar" data-state="expanded" data-mobile="closed" class="group/sidebar" ${attrs}>
      <div data-wabi--sidebar-target="backdrop"></div>
      <aside data-wabi--sidebar-target="panel" tabindex="-1"></aside>
      <main id="main">content</main>
    </div>`
  return mount(ID, Controller, FIXTURE)
}
const ctrlOf = (h) => controllerFor(h.application, ID, root())

beforeEach(() => { localStorage.clear() })
afterEach(() => { localStorage.clear() })

describe("wabi--sidebar", () => {
  it("desktop toggle flips data-state and persists to localStorage", async () => {
    setViewport(true)
    const h = mountSidebar(`data-wabi--sidebar-persist-key-value="k"`)
    await tick()
    ctrlOf(h).toggle()
    expect(root().dataset.state).toBe("collapsed")
    expect(localStorage.getItem("k")).toBe("true")
    ctrlOf(h).toggle()
    expect(root().dataset.state).toBe("expanded")
    expect(localStorage.getItem("k")).toBe("false")
  })

  it("restores collapsed state from localStorage on connect", async () => {
    setViewport(true)
    localStorage.setItem("k", "true")
    const h = mountSidebar(`data-wabi--sidebar-persist-key-value="k"`)
    await tick()
    expect(root().dataset.state).toBe("collapsed")
  })

  it("mobile toggle flips data-mobile and sets inert on non-panel/backdrop children", async () => {
    setViewport(false)
    const h = mountSidebar()
    await tick()
    ctrlOf(h).toggle()
    expect(root().dataset.mobile).toBe("open")
    expect(document.getElementById("main").hasAttribute("inert")).toBe(true)
    ctrlOf(h).toggle()
    expect(root().dataset.mobile).toBe("closed")
    expect(document.getElementById("main").hasAttribute("inert")).toBe(false)
  })

  it("Escape closes the mobile sidebar", async () => {
    setViewport(false)
    const h = mountSidebar()
    await tick()
    ctrlOf(h).toggle()
    expect(root().dataset.mobile).toBe("open")
    document.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape" }))
    await tick()
    expect(root().dataset.mobile).toBe("closed")
  })
})
