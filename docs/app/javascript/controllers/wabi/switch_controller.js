import { Controller } from "@hotwired/stimulus"
import * as switchMachine from "@zag-js/switch"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["control", "thumb", "hiddenInput", "label"]
  static values  = {
    checked:  { type: Boolean, default: false },
    disabled: { type: Boolean, default: false },
    inputId:  String,
    name:     String,
  }

  connect() {
    this.machine = new VanillaMachine(switchMachine.machine, {
      id: this.element.id || crypto.randomUUID(),
      ids: this.inputIdValue ? { hiddenInput: this.inputIdValue } : undefined,
      defaultChecked: this.checkedValue,
      disabled: this.disabledValue,
      name: this.nameValue || undefined,
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
    const api = switchMachine.connect(this.machine.service, normalizeProps)
    spreadProps(this.element,           api.getRootProps())
    if (this.hasControlTarget)     spreadProps(this.controlTarget,     api.getControlProps())
    if (this.hasThumbTarget)       spreadProps(this.thumbTarget,       api.getThumbProps())
    if (this.hasLabelTarget)       spreadProps(this.labelTarget,       api.getLabelProps())
    if (this.hasHiddenInputTarget) {
      spreadProps(this.hiddenInputTarget, api.getHiddenInputProps())
      // Zag's getHiddenInputProps always points aria-labelledby at the label
      // part. With no visible label rendered that id is dangling (empty target,
      // no accessible name). Drop it so a caller-supplied aria-label wins.
      if (!this.hasLabelTarget) {
        this.hiddenInputTarget.removeAttribute("aria-labelledby")
      }
    }
  }
}
