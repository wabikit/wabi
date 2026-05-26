import { Controller } from "@hotwired/stimulus"
import * as checkbox from "@zag-js/checkbox"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["control", "indicator", "hiddenInput"]
  static values  = {
    checked:  { type: Boolean, default: false },
    disabled: { type: Boolean, default: false },
    inputId:  String,
    name:     String,
    value:    { type: String, default: "1" },
  }

  connect() {
    this.machine = new VanillaMachine(checkbox.machine, {
      id: this.element.id || crypto.randomUUID(),
      // Pin the hidden input's id so an external <label for="..."> still resolves to it.
      ids: this.inputIdValue ? { hiddenInput: this.inputIdValue } : undefined,
      defaultChecked: this.checkedValue,
      disabled: this.disabledValue,
      name: this.nameValue || undefined,
      value: this.valueValue,
      onCheckedChange: ({ checked }) => {
        this.checkedValue = checked
        this.dispatch("change", { detail: { checked } })
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
    const api = checkbox.connect(this.machine.service, normalizeProps)
    spreadProps(this.element,           api.getRootProps())
    if (this.hasControlTarget)     spreadProps(this.controlTarget,     api.getControlProps())
    if (this.hasIndicatorTarget)   spreadProps(this.indicatorTarget,   api.getIndicatorProps())
    if (this.hasHiddenInputTarget) spreadProps(this.hiddenInputTarget, api.getHiddenInputProps())
  }
}
