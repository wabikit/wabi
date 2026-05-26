import { Controller } from "@hotwired/stimulus"
import * as accordion from "@zag-js/accordion"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["item", "trigger", "content"]
  static values  = {
    multiple:    { type: Boolean, default: false },
    value:       Array,
    collapsible: { type: Boolean, default: true },
  }

  connect() {
    this.machine = new VanillaMachine(accordion.machine, {
      id: this.element.id || crypto.randomUUID(),
      multiple: this.multipleValue,
      defaultValue: this.valueValue,
      collapsible: this.collapsibleValue,
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
    const api = accordion.connect(this.machine.service, normalizeProps)
    this.itemTargets.forEach((el) => {
      const value = el.dataset.wabiValue
      spreadProps(el, api.getItemProps({ value }))
    })
    this.triggerTargets.forEach((el) => {
      const value = el.dataset.wabiValue
      spreadProps(el, api.getItemTriggerProps({ value }))
    })
    this.contentTargets.forEach((el) => {
      const value = el.dataset.wabiValue
      spreadProps(el, api.getItemContentProps({ value }))
      // Zag emits `hidden: !open` on the content part. We animate via
      // grid-template-rows + data-state instead, so force hidden off to keep
      // the transition alive (same pattern as the Sprint 4 overlay cleanup).
      el.hidden = false
    })
  }
}
