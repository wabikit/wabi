import { describe, it, expect } from "vitest"
import Controller from "./color_picker_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, root, byTarget } from "../../test/support/overlay.js"
import * as colorPicker from "@zag-js/color-picker"
import { parseColor } from "@zag-js/color-utils"
import { normalizeProps } from "@zag-js/vanilla"

const ID = "wabi--color-picker"
const HTML = `
  <div data-controller="wabi--color-picker"
       data-wabi--color-picker-value-value="#3b82f6"
       data-wabi--color-picker-format-value="rgba"
       data-wabi--color-picker-name-value="brand">
    <div data-wabi--color-picker-target="control">
      <button data-wabi--color-picker-target="trigger">
        <span data-wabi--color-picker-target="valueSwatch"></span>
        <span data-wabi--color-picker-target="valueText"></span>
      </button>
    </div>
    <div data-wabi--color-picker-target="positioner" class="pointer-events-none">
      <div data-wabi--color-picker-target="content" data-state="closed">
        <div data-wabi--color-picker-target="area">
          <div data-wabi--color-picker-target="areaBackground"></div>
          <div data-wabi--color-picker-target="areaThumb"></div>
        </div>
        <div data-wabi--color-picker-target="channelSlider" data-wabi-channel="hue">
          <div data-wabi--color-picker-target="channelSliderTrack" data-wabi-channel="hue"></div>
          <div data-wabi--color-picker-target="channelSliderThumb" data-wabi-channel="hue"></div>
        </div>
        <input data-wabi--color-picker-target="channelInput" data-wabi-channel="hex" />
        <div data-wabi--color-picker-target="swatchGroup">
          <button data-wabi--color-picker-target="swatch" data-wabi-value="#ef4444">
            <div data-wabi--color-picker-swatch="bg"></div>
            <div data-wabi--color-picker-swatch="indicator"></div>
          </button>
        </div>
      </div>
    </div>
    <input type="hidden" name="brand" value="#3b82f6" data-wabi--color-picker-target="hiddenInput" />
  </div>`

const content = () => byTarget(ID, "content")

describe("wabi--color-picker", () => {
  it("portals the positioner to <body> on connect", async () => {
    mount(ID, Controller, HTML)
    await tick()
    const positioner = byTarget(ID, "positioner")
    expect(positioner.parentNode).toBe(document.body)
  })

  it("opens the content and dispatches :change with the value string", async () => {
    const h = mount(ID, Controller, HTML)
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    const seen = []
    document.addEventListener("wabi--color-picker:change", (e) => seen.push(e.detail.value))
    const api = colorPicker.connect(ctrl.machine.service, normalizeProps)
    api.setOpen(true)
    await tick()
    expect(content().getAttribute("data-state")).toBe("open")
    colorPicker.connect(ctrl.machine.service, normalizeProps).setValue(parseColor("#ff0000"))
    await tick()
    expect(seen.length).toBeGreaterThan(0)
    expect(seen[seen.length - 1].toLowerCase()).toContain("255")
  })

  it("mirrors the value onto the hidden input", async () => {
    const h = mount(ID, Controller, HTML)
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    colorPicker.connect(ctrl.machine.service, normalizeProps).setValue(parseColor("#00ff00"))
    await tick()
    const hidden = byTarget(ID, "hiddenInput")
    expect(hidden.value.toLowerCase()).toContain("255")
  })

  it("restores the positioner to its original parent on disconnect", async () => {
    const h = mount(ID, Controller, HTML)
    await tick()
    const ctrl = controllerFor(h.application, ID, root())
    ctrl.disconnect()
    const positioner = byTarget(ID, "positioner")
    expect(positioner.closest('[data-controller="wabi--color-picker"]')).not.toBeNull()
  })
})
