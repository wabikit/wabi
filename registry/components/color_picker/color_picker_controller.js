import { Controller } from "@hotwired/stimulus"
import * as colorPicker from "@zag-js/color-picker"
import { parseColor } from "@zag-js/color-utils"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"
import { capturePortalRefs, attachToBody, restoreFromBody } from "controllers/wabi/_shared/overlay_portal"

export default class extends Controller {
  static targets = [
    "label", "control", "trigger", "valueSwatch", "valueText",
    "positioner", "content", "area", "areaBackground", "areaThumb",
    "channelSlider", "channelSliderTrack", "channelSliderThumb",
    "channelInput", "swatchGroup", "swatch", "hiddenInput",
  ]
  static values = {
    value:  { type: String, default: "#000000" },
    format: { type: String, default: "rgba" },
    name:   String,
  }

  connect() {
    capturePortalRefs(this)
    attachToBody(this)

    let initial
    try { initial = parseColor(this.valueValue) } catch { initial = parseColor("#000000") }

    this.machine = new VanillaMachine(colorPicker.machine, {
      id: this.element.id || crypto.randomUUID(),
      defaultValue: initial,
      defaultFormat: this.formatValue,
      name: this.nameValue || undefined,
      onValueChange: ({ valueAsString }) => {
        this.dispatch("change", { detail: { value: valueAsString, valueAsString } })
      },
      onOpenChange: ({ open }) => {
        if (this.contentEl) {
          if (open) this.contentEl.removeAttribute("inert")
          else this.contentEl.setAttribute("inert", "")
        }
        this.dispatch("open-change", { detail: { open } })
      },
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.render()
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
    restoreFromBody(this)
  }

  render() {
    const api = colorPicker.connect(this.machine.service, normalizeProps)

    // Parts that stay in the controller subtree.
    if (this.hasLabelTarget) spreadProps(this.labelTarget, api.getLabelProps())
    if (this.hasControlTarget) spreadProps(this.controlTarget, api.getControlProps())
    if (this.hasTriggerTarget) spreadProps(this.triggerTarget, api.getTriggerProps())
    if (this.hasValueTextTarget) {
      spreadProps(this.valueTextTarget, api.getValueTextProps())
      this.valueTextTarget.textContent = api.valueAsString
    }
    if (this.hasValueSwatchTarget) this.valueSwatchTarget.style.background = api.valueAsString
    if (this.hasHiddenInputTarget) {
      spreadProps(this.hiddenInputTarget, api.getHiddenInputProps())
      this.hiddenInputTarget.value = api.valueAsString
    }

    // Positioner stays a target (it's the portaled node, still referenced via positionerEl).
    if (this.positionerEl) spreadProps(this.positionerEl, api.getPositionerProps())
    if (this.contentEl) {
      spreadProps(this.contentEl, api.getContentProps())
      this.contentEl.hidden = false
    }

    // In-content parts live under <body> now (the Sprint 9 trap) — query the captured
    // contentEl, NOT Stimulus *Targets (which stop resolving once portaled).
    const c = this.contentEl
    if (!c) return
    const q = (sel) => c.querySelector(sel)
    const qa = (sel) => c.querySelectorAll(sel)

    const area = q('[data-wabi--color-picker-target="area"]')
    if (area) spreadProps(area, api.getAreaProps())
    const areaBg = q('[data-wabi--color-picker-target="areaBackground"]')
    if (areaBg) spreadProps(areaBg, api.getAreaBackgroundProps())
    const areaThumb = q('[data-wabi--color-picker-target="areaThumb"]')
    if (areaThumb) spreadProps(areaThumb, api.getAreaThumbProps())

    qa('[data-wabi--color-picker-target="channelSlider"]').forEach((el) =>
      spreadProps(el, api.getChannelSliderProps({ channel: el.dataset.wabiChannel })))
    qa('[data-wabi--color-picker-target="channelSliderTrack"]').forEach((el) =>
      spreadProps(el, api.getChannelSliderTrackProps({ channel: el.dataset.wabiChannel })))
    qa('[data-wabi--color-picker-target="channelSliderThumb"]').forEach((el) =>
      spreadProps(el, api.getChannelSliderThumbProps({ channel: el.dataset.wabiChannel })))
    qa('[data-wabi--color-picker-target="channelInput"]').forEach((el) =>
      spreadProps(el, api.getChannelInputProps({ channel: el.dataset.wabiChannel })))

    const swatchGroup = q('[data-wabi--color-picker-target="swatchGroup"]')
    if (swatchGroup) spreadProps(swatchGroup, api.getSwatchGroupProps())
    qa('[data-wabi--color-picker-target="swatch"]').forEach((el) => {
      const value = el.dataset.wabiValue
      spreadProps(el, api.getSwatchTriggerProps({ value }))
      const bg = el.querySelector('[data-wabi--color-picker-swatch="bg"]')
      if (bg) spreadProps(bg, api.getSwatchProps({ value }))
      const ind = el.querySelector('[data-wabi--color-picker-swatch="indicator"]')
      if (ind) spreadProps(ind, api.getSwatchIndicatorProps({ value }))
    })
  }
}
