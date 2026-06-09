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

function fieldFixture(attrs = "") {
  return `
    <div data-controller="wabi--date-picker"
         data-wabi--date-picker-name-value="d"
         data-wabi--date-picker-selection-mode-value="single"
         data-wabi--date-picker-locale-value="en-US"
         data-wabi--date-picker-num-of-months-value="1"
         data-wabi--date-picker-portal-value="false"
         ${attrs}>
      <div data-wabi--date-picker-target="control">
        <input data-wabi--date-picker-target="input" />
        <button data-wabi--date-picker-target="trigger">cal</button>
      </div>
      <div data-wabi--date-picker-target="positioner">
        <div data-wabi--date-picker-target="content" data-state="closed" inert hidden>
          <div data-wabi--date-picker-target="viewControl">
            <button data-wabi--date-picker-target="prev">‹</button>
            <button data-wabi--date-picker-target="viewTrigger"></button>
            <button data-wabi--date-picker-target="next">›</button>
          </div>
          <table><thead><tr data-wabi--date-picker-target="gridHead"></tr></thead>
            <tbody data-wabi--date-picker-target="grid"></tbody></table>
        </div>
      </div>
      <input type="hidden" name="d" data-wabi--date-picker-target="hiddenStart" />
    </div>`
}

describe("wabi--date-picker (field open/close)", () => {
  it("starts closed, opens on trigger click, and closes again (portal:false keeps it in-tree)", async () => {
    const h = mount(ID, Controller, fieldFixture())
    await tick()
    const content = root().querySelector('[data-wabi--date-picker-target="content"]')
    expect(content.getAttribute("data-state")).toBe("closed")
    ctrlOf(h).triggerTarget.click()
    await tick()
    expect(content.getAttribute("data-state")).toBe("open")
    expect(content.hasAttribute("inert")).toBe(false)
    ctrlOf(h).triggerTarget.click()
    await tick()
    expect(content.getAttribute("data-state")).toBe("closed")
    expect(content.hasAttribute("inert")).toBe(true)
  })

  it("fills the grid inside the popover content", async () => {
    mount(ID, Controller, fieldFixture(`data-wabi--date-picker-default-value-value="2026-06-15"`))
    await tick()
    const cells = root().querySelectorAll('[data-wabi--date-picker-target="grid"] button')
    expect(cells.length).toBeGreaterThanOrEqual(28)
  })
})

function rangeFixture(attrs = "") {
  return `
    <div data-controller="wabi--date-picker"
         data-wabi--date-picker-name-value="stay"
         data-wabi--date-picker-selection-mode-value="range"
         data-wabi--date-picker-locale-value="en-US"
         data-wabi--date-picker-num-of-months-value="2"
         ${attrs}>
      <div data-wabi--date-picker-target="viewControl">
        <button data-wabi--date-picker-target="prev">‹</button>
        <button data-wabi--date-picker-target="viewTrigger"></button>
        <button data-wabi--date-picker-target="next">›</button>
      </div>
      <table><thead><tr data-wabi--date-picker-target="gridHead"></tr></thead>
        <tbody data-wabi--date-picker-target="grid"></tbody></table>
      <input type="hidden" name="stay[start]" data-wabi--date-picker-target="hiddenStart" />
      <input type="hidden" name="stay[end]" data-wabi--date-picker-target="hiddenEnd" />
    </div>`
}

describe("wabi--date-picker (range)", () => {
  it("pre-fills both hidden inputs from a default range", async () => {
    mount(ID, Controller, rangeFixture(`data-wabi--date-picker-default-value-value="2026-06-10,2026-06-14"`))
    await tick()
    expect(root().querySelector('[data-wabi--date-picker-target="hiddenStart"]').value).toBe("2026-06-10")
    expect(root().querySelector('[data-wabi--date-picker-target="hiddenEnd"]').value).toBe("2026-06-14")
  })

  it("selecting two days fills start then end", async () => {
    mount(ID, Controller, rangeFixture(`data-wabi--date-picker-default-value-value="2026-06-01,2026-06-01"`))
    await tick()
    const dayButtons = (txt) => [...root().querySelectorAll('[data-wabi--date-picker-target="grid"] button')]
      .filter((b) => b.textContent.trim() === txt)
    dayButtons("10")[0].click(); await tick()
    dayButtons("14")[0].click(); await tick()
    const start = root().querySelector('[data-wabi--date-picker-target="hiddenStart"]').value
    const end = root().querySelector('[data-wabi--date-picker-target="hiddenEnd"]').value
    expect(start).toBe("2026-06-10")
    expect(end).toBe("2026-06-14")
  })
})

function rangeFieldFixture(attrs = "") {
  return `
    <div data-controller="wabi--date-picker"
         data-wabi--date-picker-name-value="stay"
         data-wabi--date-picker-selection-mode-value="range"
         data-wabi--date-picker-locale-value="en-US"
         data-wabi--date-picker-num-of-months-value="2"
         data-wabi--date-picker-portal-value="false"
         ${attrs}>
      <div data-wabi--date-picker-target="control">
        <input data-wabi--date-picker-target="input" />
        <button data-wabi--date-picker-target="trigger">cal</button>
      </div>
      <div data-wabi--date-picker-target="positioner">
        <div data-wabi--date-picker-target="content" data-state="closed" inert hidden>
          <div data-wabi--date-picker-target="viewControl">
            <button data-wabi--date-picker-target="prev">‹</button>
            <button data-wabi--date-picker-target="viewTrigger"></button>
            <button data-wabi--date-picker-target="next">›</button>
          </div>
          <table><thead><tr data-wabi--date-picker-target="gridHead"></tr></thead>
            <tbody data-wabi--date-picker-target="grid"></tbody></table>
        </div>
      </div>
      <input type="hidden" name="stay[start]" data-wabi--date-picker-target="hiddenStart" />
      <input type="hidden" name="stay[end]" data-wabi--date-picker-target="hiddenEnd" />
    </div>`
}

describe("wabi--date-picker (range field display)", () => {
  // Regression: a single collapsed field showed only the start date because
  // Zag's getInputProps() reflects index 0. The field must show the whole range.
  it("shows both endpoints joined (start – end) in the single input", async () => {
    const h = mount(ID, Controller, rangeFieldFixture(`data-wabi--date-picker-default-value-value="2026-06-10,2026-06-14"`))
    await tick()
    const input = root().querySelector('[data-wabi--date-picker-target="input"]')
    const api = ctrlOf(h).api
    expect(api.valueAsString.length).toBe(2)                 // two formatted dates exist
    expect(input.value).toBe(api.valueAsString.join(" – "))  // both shown, not start-only
  })

  it("shows only the start while a range is half-picked", async () => {
    const h = mount(ID, Controller, rangeFieldFixture(`data-wabi--date-picker-default-value-value="2026-06-10"`))
    await tick()
    const input = root().querySelector('[data-wabi--date-picker-target="input"]')
    const api = ctrlOf(h).api
    expect(input.value).toBe(api.valueAsString.filter(Boolean).join(" – "))
  })
})
