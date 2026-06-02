import { describe, it, expect } from "vitest"
import Controller from "./slider_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root } from "../../test/support/overlay.js"
import * as slider from "@zag-js/slider"
import { normalizeProps } from "@zag-js/vanilla"

// jsdom has no layout → no thumb geometry/positioning/pointer-drag. We assert
// the value model + the hidden-input form mirror + :change. Value is driven via
// the connected api (same path the machine uses), since drag needs real rects.
const ID = "wabi--slider"
const api = (ctrl) => slider.connect(ctrl.machine.service, normalizeProps)
const hiddens = () => [...root().querySelectorAll(':scope > input[type="hidden"][data-wabi--slider-hidden="true"]')]

function mountSlider(attrs, thumbs = 1) {
  const thumbEls = Array.from({ length: thumbs }, (_, i) =>
    `<div data-wabi--slider-target="thumb" data-wabi-index="${i}"></div>`).join("")
  const FIXTURE = `
    <div id="sl" data-controller="wabi--slider" ${attrs}>
      <label data-wabi--slider-target="label">Vol</label>
      <div data-wabi--slider-target="control">
        <div data-wabi--slider-target="track"><div data-wabi--slider-target="range"></div></div>
        ${thumbEls}
      </div>
    </div>`
  return mount(ID, Controller, FIXTURE)
}

describe("wabi--slider", () => {
  it("single value: setting it mirrors to one hidden input + dispatches :change (teeth)", async () => {
    const h = mountSlider(`data-wabi--slider-name-value="vol" data-wabi--slider-value-value="[20]"`, 1)
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    const seen = []
    document.addEventListener("wabi--slider:change", (e) => seen.push(e.detail.value))
    api(ctrl).setValue([40])
    await tick()
    expect(ctrl.valueValue).toEqual([40])
    expect(seen[seen.length - 1]).toEqual([40])
    const hs = hiddens()
    expect(hs.length).toBe(1)
    expect(hs[0].name).toBe("vol")
    expect(hs[0].value).toBe("40")
  })

  it("range value: two thumbs mirror to NAME[min] / NAME[max]", async () => {
    const h = mountSlider(`data-wabi--slider-name-value="price" data-wabi--slider-value-value="[10,90]"`, 2)
    await tick()
    const names = hiddens().map((i) => i.name).sort()
    expect(names).toEqual(["price[max]", "price[min]"])
    const byName = Object.fromEntries(hiddens().map((i) => [i.name, i.value]))
    expect(byName["price[min]"]).toBe("10")
    expect(byName["price[max]"]).toBe("90")
  })
})
