import { Controller } from "@hotwired/stimulus"
import * as switchMachine from "@zag-js/switch"
import { normalizeProps, spreadProps } from "@zag-js/dom-query"

export default class extends Controller {
  static targets = ["root", "thumb", "hiddenInput"]
  static values  = {
    checked:  { type: Boolean, default: false },
    disabled: { type: Boolean, default: false },
  }

  connect() {
    this.service = switchMachine.machine({
      id: this.element.id || crypto.randomUUID(),
      checked: this.checkedValue,
      disabled: this.disabledValue,
      onCheckedChange: ({ checked }) => {
        this.checkedValue = checked
        if (this.hasHiddenInputTarget) {
          this.hiddenInputTarget.value = checked ? "1" : "0"
        }
        this.dispatch("change", { detail: { checked } })
      },
    })
    this.service.subscribe(() => this.render())
    this.service.start()
  }

  disconnect() { this.service.stop() }

  render() {
    const api = switchMachine.connect(this.service.state, this.service.send, normalizeProps)
    spreadProps(this.rootTarget, api.getControlProps())
    this.rootTarget.dataset.state = api.checked ? "checked" : "unchecked"
    if (this.hasThumbTarget) {
      this.thumbTarget.dataset.state = api.checked ? "checked" : "unchecked"
    }
  }
}
