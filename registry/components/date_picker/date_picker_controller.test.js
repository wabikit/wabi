import { describe, it, expect } from "vitest"
import Controller from "./date_picker_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"

const ID = "wabi--date-picker"

function calendarFixture(attrs = "") {
  return `
    <div data-controller="wabi--date-picker"
         data-wabi--date-picker-name-value="event[date]"
         data-wabi--date-picker-selection-mode-value="single"
         data-wabi--date-picker-locale-value="en-US"
         data-wabi--date-picker-num-of-months-value="1"
         ${attrs}>
      <div data-wabi--date-picker-target="viewControl">
        <button data-wabi--date-picker-target="prev">‹</button>
        <button data-wabi--date-picker-target="viewTrigger"></button>
        <button data-wabi--date-picker-target="next">›</button>
      </div>
      <table><thead><tr data-wabi--date-picker-target="gridHead"></tr></thead>
        <tbody data-wabi--date-picker-target="grid"></tbody></table>
      <input type="hidden" name="event[date]" data-wabi--date-picker-target="hiddenStart" />
    </div>`
}
const ctrlOf = (h) => controllerFor(h.application, ID, root())

describe("wabi--date-picker (calendar core)", () => {
  it("builds the day grid from the machine on connect", async () => {
    mount(ID, Controller, calendarFixture())
    await tick()
    const cells = root().querySelectorAll('[data-wabi--date-picker-target="grid"] button')
    expect(cells.length).toBeGreaterThanOrEqual(28)
    expect(root().querySelectorAll('[data-wabi--date-picker-target="gridHead"] th').length).toBe(7)
  })

  it("selecting a day writes ISO YYYY-MM-DD into the hidden input", async () => {
    mount(ID, Controller, calendarFixture(`data-wabi--date-picker-default-value-value="2026-06-15"`))
    await tick()
    const hidden = root().querySelector('[data-wabi--date-picker-target="hiddenStart"]')
    expect(hidden.value).toBe("2026-06-15")
    const target = [...root().querySelectorAll('[data-wabi--date-picker-target="grid"] button')]
      .find((b) => b.textContent.trim() === "20")
    target.click()
    await tick()
    expect(hidden.value).toBe("2026-06-20")
  })

  it("clicking next advances the visible month label", async () => {
    const h = mount(ID, Controller, calendarFixture(`data-wabi--date-picker-default-value-value="2026-06-15"`))
    await tick()
    const before = root().querySelector('[data-wabi--date-picker-target="viewTrigger"]').textContent
    ctrlOf(h).nextTarget.click()
    await tick()
    const after = root().querySelector('[data-wabi--date-picker-target="viewTrigger"]').textContent
    expect(after).not.toBe(before)
  })
})
