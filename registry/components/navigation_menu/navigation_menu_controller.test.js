import { describe, it, expect } from "vitest"
import Controller from "./navigation_menu_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"
import * as navigationMenu from "@zag-js/navigation-menu"
import { normalizeProps } from "@zag-js/vanilla"

const ID = "wabi--navigation-menu"
const HTML = `
  <nav data-controller="wabi--navigation-menu">
    <ul data-wabi--navigation-menu-target="list">
      <li data-wabi--navigation-menu-target="item" data-wabi-value="products">
        <button data-wabi--navigation-menu-target="trigger" data-wabi-value="products">Products</button>
        <div data-wabi--navigation-menu-target="content" data-wabi-value="products" data-state="closed">Body</div>
      </li>
      <li data-wabi--navigation-menu-target="item" data-wabi-value="company">
        <button data-wabi--navigation-menu-target="trigger" data-wabi-value="company">Company</button>
        <div data-wabi--navigation-menu-target="content" data-wabi-value="company" data-state="closed">Body2</div>
      </li>
    </ul>
  </nav>`

describe("wabi--navigation-menu", () => {
  it("opens the matching content when a value is set", async () => {
    const h = mount(ID, Controller, HTML)
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    navigationMenu.connect(ctrl.machine.service, normalizeProps).setValue("products")
    await tick()
    const content = root().querySelector('[data-wabi-value="products"][data-wabi--navigation-menu-target="content"]')
    expect(content.getAttribute("data-state")).toBe("open")
    expect(content.hasAttribute("inert")).toBe(false)
    const company = root().querySelector('[data-wabi-value="company"][data-wabi--navigation-menu-target="content"]')
    expect(company.hasAttribute("inert")).toBe(true)
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
})
