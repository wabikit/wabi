import { Controller } from "@hotwired/stimulus"
import * as radioGroup from "@zag-js/radio-group"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["item", "itemControl", "itemText", "itemIndicator", "hiddenInput"]
  static values  = {
    name:     String,
    value:    String,
    disabled: { type: Boolean, default: false },
  }

  connect() {
    this.machine = new VanillaMachine(radioGroup.machine, {
      id: this.element.id || crypto.randomUUID(),
      name: this.nameValue || undefined,
      defaultValue: this.valueValue || undefined,
      disabled: this.disabledValue,
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
    const api = radioGroup.connect(this.machine.service, normalizeProps)
    spreadProps(this.element, api.getRootProps())

    this.itemTargets.forEach((el) => {
      const value = el.dataset.wabiValue
      spreadProps(el, api.getItemProps({ value }))
    })

    this.itemControlTargets.forEach((el) => {
      const value = el.dataset.wabiValue
      spreadProps(el, api.getItemControlProps({ value }))
    })

    this.itemTextTargets.forEach((el) => {
      const value = el.dataset.wabiValue
      spreadProps(el, api.getItemTextProps({ value }))
    })

    this.itemIndicatorTargets.forEach((el) => {
      // Indicator visibility is mirrored from the closest item's data-state.
      const item = el.closest('[data-wabi--radio-group-target="item"]')
      if (!item) return
      el.dataset.state = item.dataset.state || "unchecked"
    })

    this.hiddenInputTargets.forEach((el) => {
      const value = el.dataset.wabiValue
      spreadProps(el, api.getItemHiddenInputProps({ value }))
    })
  }
}
