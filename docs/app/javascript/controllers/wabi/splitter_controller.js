import { Controller } from "@hotwired/stimulus"
import * as splitter from "@zag-js/splitter"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["panel", "resizeTrigger"]
  static values  = {
    panels:      Array,
    orientation: { type: String, default: "horizontal" },
    defaultSize: Array,
  }

  connect() {
    this.machine = new VanillaMachine(splitter.machine, {
      id: this.element.id || crypto.randomUUID(),
      panels: this.panelsValue,
      orientation: this.orientationValue,
      defaultSize: this.defaultSizeValue.length ? this.defaultSizeValue : undefined,
      onResize: ({ size }) => this.dispatch("change", { detail: { size } }),
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.render()
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
  }

  render() {
    const api = splitter.connect(this.machine.service, normalizeProps)
    spreadProps(this.element, api.getRootProps())
    this.panelTargets.forEach((el) => spreadProps(el, api.getPanelProps({ id: el.dataset.wabiId })))
    this.resizeTriggerTargets.forEach((el) => spreadProps(el, api.getResizeTriggerProps({ id: el.dataset.wabiId })))
  }
}
