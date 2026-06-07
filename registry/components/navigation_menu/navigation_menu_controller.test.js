import { describe, it, expect } from "vitest"
import Controller from "./navigation_menu_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root, allByTarget } from "../../test/support/overlay.js"
import * as navigationMenu from "@zag-js/navigation-menu"
import { normalizeProps } from "@zag-js/vanilla"

const ID = "wabi--navigation-menu"
const HTML = `
  <nav data-controller="wabi--navigation-menu">
    <ul data-wabi--navigation-menu-target="list">
      <li data-wabi--navigation-menu-target="item" data-wabi-value="products">
        <button data-wabi--navigation-menu-target="trigger" data-wabi-value="products">Products</button>
        <div data-wabi--navigation-menu-target="content" data-wabi-value="products" data-state="closed">
          <a data-wabi--navigation-menu-target="link" data-wabi-value="products" href="#">Analytics</a>
        </div>
      </li>
      <li data-wabi--navigation-menu-target="item" data-wabi-value="company">
        <button data-wabi--navigation-menu-target="trigger" data-wabi-value="company">Company</button>
        <div data-wabi--navigation-menu-target="content" data-wabi-value="company" data-state="closed">
          <a data-wabi--navigation-menu-target="link" data-wabi-value="company" href="#">About</a>
        </div>
      </li>
    </ul>
  </nav>`

const contentByValue = (value) =>
  allByTarget(ID, "content").find((el) => el.dataset.wabiValue === value)

describe("wabi--navigation-menu", () => {
  it("portals every content panel to <body> on connect", async () => {
    mount(ID, Controller, HTML)
    await tick()
    expect(contentByValue("products").parentNode).toBe(document.body)
    expect(contentByValue("company").parentNode).toBe(document.body)
  })

  it("opens the matching panel, positions it fixed, and leaves others inert", async () => {
    const h = mount(ID, Controller, HTML)
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    navigationMenu.connect(ctrl.machine.service, normalizeProps).setValue("products")
    await tick()
    const products = contentByValue("products")
    expect(products.getAttribute("data-state")).toBe("open")
    expect(products.hasAttribute("inert")).toBe(false)
    expect(products.style.position).toBe("fixed")
    expect(contentByValue("company").hasAttribute("inert")).toBe(true)
  })

  it("dispatches :change when the open value changes", async () => {
    const h = mount(ID, Controller, HTML)
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    const seen = []
    document.addEventListener("wabi--navigation-menu:change", (e) => seen.push(e.detail.value))
    navigationMenu.connect(ctrl.machine.service, normalizeProps).setValue("company")
    await tick()
    expect(seen[seen.length - 1]).toBe("company")
  })

  it("restores panels to their original item on disconnect", async () => {
    const h = mount(ID, Controller, HTML)
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    ctrl.disconnect()
    const products = contentByValue("products")
    expect(products.closest('[data-wabi--navigation-menu-target="item"]')).not.toBeNull()
  })

  it("re-portals panels to <body> after a disconnect/connect cycle", async () => {
    const h = mount(ID, Controller, HTML)
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    ctrl.disconnect()
    ctrl.connect()
    await tick()
    // Exactly two panels, both back at <body>, no duplicates left behind.
    const panels = allByTarget(ID, "content")
    expect(panels.length).toBe(2)
    panels.forEach((p) => expect(p.parentNode).toBe(document.body))
  })
})
