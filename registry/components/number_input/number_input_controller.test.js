import { describe, it, expect } from "vitest"
import Controller from "./number_input_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"
import * as numberInput from "@zag-js/number-input"
import { normalizeProps } from "@zag-js/vanilla"

const ID = "wabi--number-input"
const api = (ctrl) => numberInput.connect(ctrl.machine.service, normalizeProps)
const inputEl = () => root().querySelector('[data-wabi--number-input-target="input"]')
const triggerEl = (which) => root().querySelector(`[data-wabi--number-input-target="${which}"]`)

function mountNI(attrs = "") {
  const FIXTURE = `
    <div id="ni" data-controller="wabi--number-input" ${attrs}>
      <div data-wabi--number-input-target="control">
        <button data-wabi--number-input-target="decrement">−</button>
        <input data-wabi--number-input-target="input" />
        <button data-wabi--number-input-target="increment">+</button>
      </div>
    </div>`
  const h = mount(ID, Controller, FIXTURE)
  return h
}
const ctrlOf = (h) => controllerFor(h.application, ID, root())

describe("wabi--number-input", () => {
  it("increment adds one step and clamps at max", async () => {
    const h = mountNI(`data-wabi--number-input-value-value="4" data-wabi--number-input-max-value="5" data-wabi--number-input-step-value="1"`)
    await tick()
    const ctrl = ctrlOf(h)
    api(ctrl).increment()
    await tick()
    expect(inputEl().value).toBe("5")
    api(ctrl).increment()
    await tick()
    expect(inputEl().value).toBe("5") // clamped at max
  })

  it("decrement subtracts one step and clamps at min", async () => {
    const h = mountNI(`data-wabi--number-input-value-value="1" data-wabi--number-input-min-value="0" data-wabi--number-input-step-value="1"`)
    await tick()
    const ctrl = ctrlOf(h)
    api(ctrl).decrement()
    await tick()
    expect(inputEl().value).toBe("0")
    api(ctrl).decrement()
    await tick()
    expect(inputEl().value).toBe("0") // clamped at min
  })

  it("respects a custom step", async () => {
    const h = mountNI(`data-wabi--number-input-value-value="0" data-wabi--number-input-step-value="5"`)
    await tick()
    api(ctrlOf(h)).increment()
    await tick()
    expect(inputEl().value).toBe("5")
  })

  it("formats the value as currency", async () => {
    const h = mountNI(`data-wabi--number-input-value-value="1250" data-wabi--number-input-format-options-value='{"style":"currency","currency":"USD"}'`)
    await tick()
    expect(inputEl().value).toContain("$")
    expect(inputEl().value).toContain("1,250")
  })

  it("stays plain when no format-options attribute is set", async () => {
    const h = mountNI(`data-wabi--number-input-value-value="42"`)
    await tick()
    expect(inputEl().value).toBe("42")
  })

  it("marks triggers disabled when disabled-value is true", async () => {
    const h = mountNI(`data-wabi--number-input-disabled-value="true"`)
    await tick()
    const inc = triggerEl("increment")
    expect(inc.disabled || inc.hasAttribute("data-disabled")).toBe(true)
  })

  it("dispatches :change with value and valueAsNumber", async () => {
    const h = mountNI(`data-wabi--number-input-value-value="2" data-wabi--number-input-step-value="1"`)
    await tick()
    const seen = []
    document.addEventListener("wabi--number-input:change", (e) => seen.push(e.detail))
    api(ctrlOf(h)).increment()
    await tick()
    expect(seen.at(-1).value).toBe("3")
    expect(seen.at(-1).valueAsNumber).toBe(3)
  })
})
