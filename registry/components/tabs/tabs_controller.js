import { Controller } from "@hotwired/stimulus"
import * as tabs from "@zag-js/tabs"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["list", "trigger", "content"]
  static values  = {
    value:          String,
    activationMode: { type: String, default: "automatic" },
  }

  connect() {
    this.machine = new VanillaMachine(tabs.machine, {
      id: this.element.id || crypto.randomUUID(),
      defaultValue: this.valueValue,
      activationMode: this.activationModeValue,
      onValueChange: ({ value }) => {
        this.valueValue = value
        this.dispatch("change", { detail: { value } })
      },
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
    const api = tabs.connect(this.machine.service, normalizeProps)
    if (this.hasListTarget) spreadProps(this.listTarget, api.getListProps())
    this.triggerTargets.forEach((el) => {
      spreadProps(el, api.getTriggerProps({
        value:    el.dataset.wabiValue,
        disabled: el.dataset.wabiDisabled === "true",
      }))
    })
    this.contentTargets.forEach((el) => {
      const value = el.dataset.wabiValue
      spreadProps(el, api.getContentProps({ value }))
      el.hidden = api.value !== value
    })
  }
}
