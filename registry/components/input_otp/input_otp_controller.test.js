import { describe, it, expect } from "vitest"
import Controller from "./input_otp_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"
import * as pinInput from "@zag-js/pin-input"
import { normalizeProps } from "@zag-js/vanilla"

const ID = "wabi--input-otp"
const api = (ctrl) => pinInput.connect(ctrl.machine.service, normalizeProps)

function fixture(length = 4, attrs = "") {
  const slots = Array.from({ length }, () =>
    `<input data-wabi--input-otp-target="slot" />`).join("")
  return `
    <div id="otp" data-controller="wabi--input-otp"
         data-wabi--input-otp-name-value="code"
         data-wabi--input-otp-length-value="${length}"
         data-wabi--input-otp-type-value="numeric"
         data-wabi--input-otp-otp-value="true"
         data-wabi--input-otp-mask-value="false"
         ${attrs}>
      ${slots}
      <input type="hidden" name="code" data-wabi--input-otp-target="hiddenValue" />
    </div>`
}

describe("wabi--input-otp", () => {
  it("wires each slot to the machine on connect", async () => {
    mount(ID, Controller, fixture(4))
    await tick()
    const slots = root().querySelectorAll('[data-wabi--input-otp-target="slot"]')
    expect(slots.length).toBe(4)
    // Zag spreads getRootProps onto the root and getInputProps onto each slot;
    // a reliable indicator is data-part or aria-label applied by Zag.
    expect(slots[0].getAttribute("aria-label") || slots[0].id || slots[0].getAttribute("data-part")).toBeTruthy()
  })

  it("syncs the concatenated value into the hidden input", async () => {
    const h = mount(ID, Controller, fixture(4))
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    const hidden = root().querySelector('[data-wabi--input-otp-target="hiddenValue"]')
    // Drive the machine via its public API so the value change propagates
    // through onValueChange and syncHidden regardless of jsdom event quirks.
    api(ctrl).setValue(["1", "2", "3", "4"])
    await tick()
    expect(hidden.value).toBe("1234")
  })

  it("pre-fills the hidden input from default_value", async () => {
    mount(ID, Controller, fixture(4, `data-wabi--input-otp-default-value-value="99"`))
    await tick()
    expect(root().querySelector('[data-wabi--input-otp-target="hiddenValue"]').value).toBe("99")
  })

  it("dispatches :change when the value changes", async () => {
    const h = mount(ID, Controller, fixture(4))
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    const seen = []
    document.addEventListener("wabi--input-otp:change", (e) => seen.push(e.detail))
    api(ctrl).setValue(["5", "6", "7", "8"])
    await tick()
    expect(seen.at(-1)?.value).toBe("5678")
  })

  it("marks inputs disabled when disabled-value is true", async () => {
    mount(ID, Controller, fixture(4, `data-wabi--input-otp-disabled-value="true"`))
    await tick()
    const slots = root().querySelectorAll('[data-wabi--input-otp-target="slot"]')
    const anyDisabled = [...slots].some(el => el.disabled || el.hasAttribute("data-disabled"))
    expect(anyDisabled).toBe(true)
  })
})
