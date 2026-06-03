import { Controller } from "@hotwired/stimulus"
import * as numberInput from "@zag-js/number-input"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["control", "input", "decrement", "increment"]
  static values = {
    name:            String,
    value:           String,
    min:             String,
    max:             String,
    step:            { type: Number, default: 1 },
    formatOptions:   Object,
    allowMouseWheel: { type: Boolean, default: false },
    invalid:         { type: Boolean, default: false },
    disabled:        { type: Boolean, default: false },
  }

  connect() {
    this.machine = new VanillaMachine(numberInput.machine, {
      id: this.element.id || crypto.randomUUID(),
      name: this.nameValue || undefined,
      // defaultValue (not value) keeps the machine uncontrolled — it owns state.
      defaultValue: this.valueValue !== "" ? this.valueValue : undefined,
      // Stimulus String values default to ""; coerce to Number only when set,
      // otherwise pass undefined so Zag applies no bound (Number("") is 0, not NaN).
      min: this.minValue !== "" ? Number(this.minValue) : undefined,
      max: this.maxValue !== "" ? Number(this.maxValue) : undefined,
      step: this.stepValue,
      // Stimulus Object values default to {}, which is truthy — Zag would then
      // activate Intl formatting and drop the input pattern. Pass undefined when
      // empty so a controller mounted without a format-options attr stays plain.
      formatOptions: Object.keys(this.formatOptionsValue).length > 0 ? this.formatOptionsValue : undefined,
      allowMouseWheel: this.allowMouseWheelValue,
      invalid: this.invalidValue,
      disabled: this.disabledValue,
      onValueChange: ({ value, valueAsNumber }) => {
        this.dispatch("change", { detail: { value, valueAsNumber } })
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
    const api = numberInput.connect(this.machine.service, normalizeProps)
    spreadProps(this.element, api.getRootProps())
    if (this.hasControlTarget)   spreadProps(this.controlTarget,   api.getControlProps())
    if (this.hasInputTarget)     spreadProps(this.inputTarget,     api.getInputProps())
    if (this.hasDecrementTarget) spreadProps(this.decrementTarget, api.getDecrementTriggerProps())
    if (this.hasIncrementTarget) spreadProps(this.incrementTarget, api.getIncrementTriggerProps())
  }
}
