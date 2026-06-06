import { describe, it, expect } from "vitest"
import Controller from "./rating_group_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"
import * as ratingGroup from "@zag-js/rating-group"
import { normalizeProps } from "@zag-js/vanilla"

const ID = "wabi--rating-group"
const api = (ctrl) => ratingGroup.connect(ctrl.machine.service, normalizeProps)

function fixture(count = 5, value = -1, attrs = "") {
  const items = Array.from({ length: count }, (_, i) =>
    `<span data-wabi--rating-group-target="item" data-wabi-index="${i + 1}">★</span>`
  ).join("")
  return `
    <div id="rg" data-controller="wabi--rating-group"
         data-wabi--rating-group-name-value="score"
         data-wabi--rating-group-count-value="${count}"
         data-wabi--rating-group-value-value="${value}"
         ${attrs}>
      <label data-wabi--rating-group-target="label">Rating</label>
      <div role="radiogroup" data-wabi--rating-group-target="control">
        ${items}
      </div>
      <input type="hidden" name="score" data-wabi--rating-group-target="hiddenInput" />
    </div>`
}

describe("wabi--rating-group", () => {
  it("wires item spans and spreads Zag props on connect", async () => {
    mount(ID, Controller, fixture(5))
    await tick()
    const items = root().querySelectorAll('[data-wabi--rating-group-target="item"]')
    expect(items.length).toBe(5)
    // Zag spreads role="radio" and aria-* onto each item
    expect(items[0].getAttribute("role")).toBe("radio")
  })

  it("the control receives role=radiogroup from Zag", async () => {
    mount(ID, Controller, fixture(5))
    await tick()
    const control = root().querySelector('[data-wabi--rating-group-target="control"]')
    expect(control.getAttribute("role")).toBe("radiogroup")
  })

  it("clicking a star updates the value and syncs the hidden input", async () => {
    const h = mount(ID, Controller, fixture(5, -1))
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    // Drive the machine via its public API
    api(ctrl).setValue(3)
    await tick()
    expect(ctrl.valueValue).toBe(3)
    const hidden = root().querySelector('[data-wabi--rating-group-target="hiddenInput"]')
    expect(hidden.value).toBe("3")
  })

  it("dispatches :change when the value changes", async () => {
    const h = mount(ID, Controller, fixture(5))
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    const seen = []
    document.addEventListener("wabi--rating-group:change", (e) => seen.push(e.detail))
    api(ctrl).setValue(4)
    await tick()
    expect(seen.at(-1)?.value).toBe(4)
  })

  it("marks items as checked when the default value is set", async () => {
    mount(ID, Controller, fixture(5, 3))
    await tick()
    const items = root().querySelectorAll('[data-wabi--rating-group-target="item"]')
    // Items at or below the value should be highlighted/checked
    const checkedOrHighlighted = [...items].filter(
      (el) => el.hasAttribute("data-checked") || el.hasAttribute("data-highlighted")
    )
    expect(checkedOrHighlighted.length).toBeGreaterThan(0)
  })

  it("disabled items get aria-disabled from Zag", async () => {
    mount(ID, Controller, fixture(5, -1, `data-wabi--rating-group-disabled-value="true"`))
    await tick()
    const items = root().querySelectorAll('[data-wabi--rating-group-target="item"]')
    const anyDisabled = [...items].some(
      (el) => el.getAttribute("aria-disabled") === "true" || el.hasAttribute("data-disabled")
    )
    expect(anyDisabled).toBe(true)
  })
})
