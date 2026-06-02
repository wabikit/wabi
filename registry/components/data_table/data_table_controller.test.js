import { describe, it, expect, beforeEach } from "vitest"
import Controller from "./data_table_controller.js"
import { mount, tick } from "../../test/support/mount.js"

const FIXTURE = `
  <div data-controller="wabi--data-table">
    <table>
      <thead><tr><th>
        <input type="checkbox" data-wabi--data-table-target="selectAll"
               data-action="change->wabi--data-table#toggleAll">
      </th></tr></thead>
      <tbody>
        <tr><td><input type="checkbox" value="1" data-wabi--data-table-target="rowCheckbox" data-action="change->wabi--data-table#toggleRow"></td></tr>
        <tr><td><input type="checkbox" value="2" data-wabi--data-table-target="rowCheckbox" data-action="change->wabi--data-table#toggleRow"></td></tr>
        <tr><td><input type="checkbox" value="3" data-wabi--data-table-target="rowCheckbox" data-action="change->wabi--data-table#toggleRow"></td></tr>
      </tbody>
    </table>
  </div>`

let harness
const rows = () => [...document.querySelectorAll('[data-wabi--data-table-target="rowCheckbox"]')]
const selectAll = () => document.querySelector('[data-wabi--data-table-target="selectAll"]')
const check = (input) => { input.checked = true; input.dispatchEvent(new Event("change", { bubbles: true })) }
const uncheck = (input) => { input.checked = false; input.dispatchEvent(new Event("change", { bubbles: true })) }

beforeEach(async () => {
  harness = mount("wabi--data-table", Controller, FIXTURE)
  await tick()
})

describe("wabi--data-table selection", () => {
  it("select-all checks every row and marks rows selected", async () => {
    const sa = selectAll()
    sa.checked = true
    sa.dispatchEvent(new Event("change", { bubbles: true }))
    await tick()
    expect(rows().every((r) => r.checked)).toBe(true)
    expect(rows().every((r) => r.closest("tr").dataset.state === "selected")).toBe(true)
  })

  it("partial row selection sets the select-all indeterminate", async () => {
    check(rows()[0])
    await tick()
    expect(selectAll().indeterminate).toBe(true)
    expect(selectAll().checked).toBe(false)
  })

  it("all rows checked individually → select-all becomes checked, not indeterminate", async () => {
    rows().forEach(check)
    await tick()
    expect(selectAll().checked).toBe(true)
    expect(selectAll().indeterminate).toBe(false)
  })

  it("unchecking a row clears its row data-state", async () => {
    check(rows()[0])
    await tick()
    expect(rows()[0].closest("tr").dataset.state).toBe("selected")
    uncheck(rows()[0])
    await tick()
    // controller uses `delete row.dataset.state` → attribute removed → undefined
    expect(rows()[0].closest("tr").dataset.state).toBeUndefined()
  })

  it("dispatches wabi--data-table:change with the selected values", async () => {
    const events = []
    document.addEventListener("wabi--data-table:change", (e) => events.push(e.detail))
    check(rows()[0])
    check(rows()[2])
    await tick()
    const last = events[events.length - 1]
    expect(last.values).toEqual(["1", "3"])
    expect(last.count).toBe(2)
  })
})
