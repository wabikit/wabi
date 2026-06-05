import { Controller } from "@hotwired/stimulus"
import * as pinInput from "@zag-js/pin-input"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["slot", "hiddenValue"]
  static values = {
    name:         String,
    length:       { type: Number, default: 6 },
    type:         { type: String, default: "numeric" },
    mask:         { type: Boolean, default: false },
    otp:          { type: Boolean, default: true },
    defaultValue: String,
    disabled:     { type: Boolean, default: false },
  }

  connect() {
    this.machine = new VanillaMachine(pinInput.machine, {
      id: this.element.id || crypto.randomUUID(),
      count: this.lengthValue,
      type: this.typeValue,
      mask: this.maskValue,
      otp: this.otpValue,
      disabled: this.disabledValue,
      // defaultValue is an array of characters; split the string value when set.
      // Stimulus String values default to "" — treat empty string as unset.
      defaultValue: this.defaultValueValue !== "" ? this.defaultValueValue.split("") : undefined,
      onValueChange: ({ valueAsString }) => {
        this.syncHidden(valueAsString)
        this.dispatch("change", { detail: { value: valueAsString } })
      },
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.render()
    // Sync the hidden input immediately (covers defaultValue pre-fill)
    this.syncHidden(this.api.valueAsString)
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
  }

  get api() {
    return pinInput.connect(this.machine.service, normalizeProps)
  }

  render() {
    const api = this.api
    spreadProps(this.element, api.getRootProps())
    this.slotTargets.forEach((el, index) => spreadProps(el, api.getInputProps({ index })))
  }

  syncHidden(value) {
    if (this.hasHiddenValueTarget) this.hiddenValueTarget.value = value ?? ""
  }
}
