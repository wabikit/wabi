import { Controller } from "@hotwired/stimulus"
import * as ratingGroup from "@zag-js/rating-group"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["label", "control", "item", "hiddenInput"]
  static values = {
    name:      String,
    value:     { type: Number, default: -1 },
    count:     { type: Number, default: 5 },
    allowHalf: { type: Boolean, default: false },
    readOnly:  { type: Boolean, default: false },
    disabled:  { type: Boolean, default: false },
  }

  connect() {
    this.machine = new VanillaMachine(ratingGroup.machine, {
      id: this.element.id || crypto.randomUUID(),
      name: this.nameValue || undefined,
      count: this.countValue,
      allowHalf: this.allowHalfValue,
      readOnly: this.readOnlyValue,
      disabled: this.disabledValue,
      // Treat the Stimulus default of -1 as "no value set" (unrated)
      defaultValue: this.valueValue >= 0 ? this.valueValue : -1,
      onValueChange: ({ value }) => {
        this.valueValue = value
        if (this.hasHiddenInputTarget) this.hiddenInputTarget.value = value >= 0 ? value : ""
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
    const api = ratingGroup.connect(this.machine.service, normalizeProps)

    spreadProps(this.element, api.getRootProps())
    if (this.hasLabelTarget)       spreadProps(this.labelTarget,       api.getLabelProps())
    if (this.hasControlTarget)     spreadProps(this.controlTarget,     api.getControlProps())
    if (this.hasHiddenInputTarget) spreadProps(this.hiddenInputTarget, api.getHiddenInputProps())

    this.itemTargets.forEach((el) => {
      const index = parseInt(el.dataset.wabiIndex, 10)
      if (index > 0) spreadProps(el, api.getItemProps({ index }))
    })
  }
}
