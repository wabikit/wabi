import { Controller } from "@hotwired/stimulus"
import * as checkbox from "@zag-js/checkbox"
import { normalizeProps, spreadProps } from "@zag-js/dom-query"

export default class extends Controller {
  static targets = ["root", "indicator", "hiddenInput"]
  static values  = {
    checked:  { type: Boolean, default: false },
    disabled: { type: Boolean, default: false },
    name:     String,
    value:    { type: String, default: "1" },
  }

  connect() {
    this.service = checkbox.machine({
      id: this.element.id || crypto.randomUUID(),
      checked: this.checkedValue,
      disabled: this.disabledValue,
      name: this.nameValue,
      value: this.valueValue,
      onCheckedChange: ({ checked }) => {
        this.checkedValue = checked
        if (this.hasHiddenInputTarget) {
          this.hiddenInputTarget.value = checked ? this.valueValue : ""
        }
        this.dispatch("change", { detail: { checked } })
      },
    })
    this.service.subscribe(() => this.render())
    this.service.start()
  }

  disconnect() { this.service.stop() }

  render() {
    const api = checkbox.connect(this.service.state, this.service.send, normalizeProps)
    spreadProps(this.rootTarget, api.getControlProps())
    if (this.hasIndicatorTarget) {
      this.indicatorTarget.hidden = !api.checked
    }
  }
}
