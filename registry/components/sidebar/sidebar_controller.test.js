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
      <button id="trigger" data-wabi--sidebar-target="trigger" data-action="wabi--sidebar#toggle">T</button>
      <input id="field" />
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

  it("mirrors collapse state to <html data-wabi-sidebar> (so portaled tooltips can gate on it)", async () => {
    setViewport(true)
    const h = mountSidebar(`data-wabi--sidebar-persist-key-value="k"`)
    await tick()
    expect(document.documentElement.getAttribute("data-wabi-sidebar")).toBe("expanded")
    ctrlOf(h).toggle()
    expect(document.documentElement.getAttribute("data-wabi-sidebar")).toBe("collapsed")
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

  it("Cmd/Ctrl+B toggles the sidebar", async () => {
    setViewport(true)
    const h = mountSidebar(`data-wabi--sidebar-persist-key-value="k"`)
    await tick()
    document.dispatchEvent(new KeyboardEvent("keydown", { key: "b", metaKey: true }))
    await tick()
    expect(root().dataset.state).toBe("collapsed")
    document.dispatchEvent(new KeyboardEvent("keydown", { key: "b", ctrlKey: true }))
    await tick()
    expect(root().dataset.state).toBe("expanded")
  })

  it("a plain 'b' keypress does not toggle", async () => {
    setViewport(true)
    const h = mountSidebar()
    await tick()
    document.dispatchEvent(new KeyboardEvent("keydown", { key: "b" }))
    await tick()
    expect(root().dataset.state).toBe("expanded")
  })

  it("Cmd/Ctrl+B is ignored while focus is in an editable field", async () => {
    setViewport(true)
    const h = mountSidebar(`data-wabi--sidebar-persist-key-value="k"`)
    await tick()
    const field = document.getElementById("field")
    field.dispatchEvent(new KeyboardEvent("keydown", { key: "b", metaKey: true, bubbles: true }))
    await tick()
    expect(root().dataset.state).toBe("expanded") // unchanged — shortcut suppressed in inputs
  })

  it("gives the panel an id and syncs aria-expanded/aria-controls on the trigger", async () => {
    setViewport(true)
    const h = mountSidebar(`data-wabi--sidebar-persist-key-value="k"`)
    await tick()
    const trigger = document.getElementById("trigger")
    const panel = root().querySelector('[data-wabi--sidebar-target="panel"]')
    expect(panel.id).toBeTruthy()
    expect(trigger.getAttribute("aria-controls")).toBe(panel.id)
    expect(trigger.getAttribute("aria-expanded")).toBe("true")
    ctrlOf(h).toggle()
    expect(trigger.getAttribute("aria-expanded")).toBe("false")
    ctrlOf(h).toggle()
    expect(trigger.getAttribute("aria-expanded")).toBe("true")
  })

  it("mobile open marks the panel as a modal dialog; close clears it", async () => {
    setViewport(false)
    const h = mountSidebar()
    await tick()
    const panel = root().querySelector('[data-wabi--sidebar-target="panel"]')
    ctrlOf(h).toggle()
    expect(panel.getAttribute("role")).toBe("dialog")
    expect(panel.getAttribute("aria-modal")).toBe("true")
    ctrlOf(h).toggle()
    expect(panel.hasAttribute("role")).toBe(false)
    expect(panel.hasAttribute("aria-modal")).toBe(false)
  })
})
